import json
from pydantic import BaseModel, Field
from typing import (
    Union,
    Generator,
    Iterator,
    List,
    Dict,
    Optional,
    Callable,
    Awaitable,
    Any,
)
import aiohttp

from open_webui.utils.misc import get_last_user_message
from open_webui.apps.webui.models.users import Users
from open_webui.main import generate_chat_completions


class Pipe:
    class Valves(BaseModel):
        ROUTER_ID: str = Field(default="semantic-router")
        ROUTER_NAME: str = Field(default="Semantic Router")
        INTENTION_MODEL: str = Field(default="llama3:latest")
        ENABLE_EMITTERS: bool = Field(default=True)
        INTENTIONS: Dict[str, Dict[str, str]] = Field(
            default={
                "chatting": {
                    "description": "The user is simply chatting.",
                    "model": "llama3:latest",
                },
                "media": {
                    "description": "The user is asking about an image or video.",
                    "model": "llama3:latest",
                },
                "code": {
                    "description": "The user is asking about code.",
                    "model": "codeqwen:latest",
                },
                "prometheus": {
                    "description": "The user is requesting a Prometheus metric.",
                    "model": "llama3:latest",
                },
            }
        )

    def __init__(self):
        self.type = "manifold"
        self.valves = self.Valves()

    def pipes(self):
        return [{"name": self.valves.ROUTER_NAME, "id": self.valves.ROUTER_ID}]

    async def determine_intention(
        self,
        query: str,
        __event_emitter__: Optional[Callable[[Any], Awaitable[None]]] = None,
    ) -> str:
        if self.valves.ENABLE_EMITTERS and __event_emitter__:
            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": "Determining intention...",
                        "done": False,
                    },
                }
            )

        query_lower = query.lower()
        if (
            "prometheus" in query_lower
            or "metric" in query_lower
            or "query" in query_lower
        ):
            intention_text = "prometheus"
        elif "image" in query_lower or "video" in query_lower:
            intention_text = "media"
        elif "code" in query_lower or "function" in query_lower:
            intention_text = "code"
        else:
            intention_text = "chatting"

        if self.valves.ENABLE_EMITTERS and __event_emitter__:
            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": f"Raw intention determined: {intention_text}",
                        "done": False,
                    },
                }
            )

        return intention_text

    async def extract_prometheus_query(
        self,
        user_message: str,
        user: dict,
    ) -> Optional[str]:
        prompt = [
            {
                "role": "system",
                "content": "You are a helpful assistant. Extract the raw Prometheus query from the user's input. Only return the query string, no extra text.",
            },
            {"role": "user", "content": user_message},
        ]

        response = await generate_chat_completions(
            form_data={"model": "llama3:latest", "messages": prompt, "stream": False},
            user=user,
        )

        try:
            return response["choices"][0]["message"]["content"].strip()
        except Exception as e:
            print(f"Failed to extract Prometheus query: {str(e)}")
            return None

    async def query_prometheus(self, prom_query: str) -> str:
        url = f"http://prometheus:9090/api/v1/query"
        async with aiohttp.ClientSession() as session:
            async with session.get(url, params={"query": prom_query}) as resp:
                data = await resp.json()
                if data.get("status") == "success":
                    results = data["data"]["result"]
                    if not results:
                        return "No data found for this query."
                    parsed_results = "\n".join(
                        f"{res['metric']} => {res['value']}" for res in results
                    )
                    return f"Prometheus query results:\n{parsed_results}"
                else:
                    return f"Prometheus error: {data.get('error', 'Unknown error')}"

    async def route_query(
        self,
        query: str,
        messages: List[Dict],
        user: Dict,
        __event_emitter__: Optional[Callable[[Any], Awaitable[None]]] = None,
    ) -> Dict[str, Any]:
        try:
            intention = await self.determine_intention(query, __event_emitter__)
            model_id = self.valves.INTENTIONS.get(
                intention, self.valves.INTENTIONS["chatting"]
            )["model"]

            if intention == "prometheus":
                prom_query = await self.extract_prometheus_query(query, user)
                if not prom_query:
                    return {
                        "choices": [
                            {
                                "message": {
                                    "content": "Couldn't understand your Prometheus query.",
                                    "role": "assistant",
                                },
                                "finish_reason": "stop",
                                "index": 0,
                            }
                        ]
                    }
                result = await self.query_prometheus(prom_query)
                return {
                    "choices": [
                        {
                            "message": {
                                "content": result,
                                "role": "assistant",
                            },
                            "finish_reason": "stop",
                            "index": 0,
                        }
                    ]
                }

            payload = {
                "model": model_id,
                "messages": messages,
                "stream": False,
            }

            response = await generate_chat_completions(form_data=payload, user=user)

            formatted_response = {
                "choices": [
                    {
                        "message": {
                            "content": response["choices"][0]["message"]["content"],
                            "role": "assistant",
                        },
                        "finish_reason": "stop",
                        "index": 0,
                    }
                ]
            }

            return formatted_response
        except Exception as e:
            print(f"Error in route_query: {str(e)}")
            return {
                "choices": [
                    {
                        "message": {
                            "content": f"An error occurred: {str(e)}",
                            "role": "assistant",
                        },
                        "finish_reason": "stop",
                        "index": 0,
                    }
                ]
            }

    async def pipe(
        self,
        body: dict,
        __user__: dict,
        __event_emitter__: Optional[Callable[[Any], Awaitable[None]]] = None,
    ) -> str:
        print(f"pipe:{__name__}")

        messages = body["messages"]
        user_message = get_last_user_message(messages)
        user = Users.get_user_by_id(__user__["id"])

        response = await self.route_query(
            user_message, messages, user, __event_emitter__
        )

        if (
            isinstance(response, dict)
            and "choices" in response
            and len(response["choices"]) > 0
        ):
            content = response["choices"][0]["message"]["content"]
        else:
            content = "Error: Unexpected response format"

        return content
