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
import re

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
                "compare": {
                    "description": "The user wants to compare two Prometheus metrics.",
                    "model": "llama3:latest",
                },
                "historical": {
                    "description": "The user is asking about history, wars, events, cultures, and civilizations.",
                    "model": "JorgeAtLLama/herodotus:latest",
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
        if "compare" in query_lower and "metric" in query_lower:
            intention_text = "compare"
        elif (
            "prometheus" in query_lower
            or "metric" in query_lower
            or "query" in query_lower
        ):
            intention_text = "prometheus"
        elif "image" in query_lower or "video" in query_lower:
            intention_text = "media"
        elif "code" in query_lower or "function" in query_lower:
            intention_text = "code"
        elif any(
            keyword in query_lower
            for keyword in [
                "history",
                "war",
                "event",
                "culture",
                "civilization",
            ]
        ):
            intention_text = "historical"
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
                "content": "You are a helpful assistant. Extract the raw Prometheus query from the user's input. Only return the query string, no extra text. If the user's request doesn't contain a clear Prometheus query, indicate that.",
            },
            {"role": "user", "content": user_message},
        ]

        response = await generate_chat_completions(
            form_data={"model": "llama3:latest", "messages": prompt, "stream": False},
            user=user,
        )

        try:
            content = response["choices"][0]["message"]["content"].strip()
            if "no clear prometheus query" in content.lower():
                return None
            return content
        except Exception as e:
            print(f"Failed to extract Prometheus query: {str(e)}")
            return None

    async def query_prometheus(self, prom_query: str) -> str:
        url = "http://prometheus:9090/api/v1/query"
        prom_query = prom_query.strip().strip("`'\"")

        async with aiohttp.ClientSession() as session:
            try:
                async with session.get(
                    url, params={"query": prom_query}, timeout=10
                ) as resp:
                    if resp.status != 200:
                        return f"Failed to connect to Prometheus. Status code: {resp.status}"

                    data = await resp.json()
                    if data.get("status") != "success":
                        return f"Prometheus error: {data.get('error', 'Unknown error')}"

                    results = data["data"].get("result", [])
                    if not results:
                        return "No data found for this query."

                    parsed_results = []
                    for res in results:
                        if not isinstance(res, dict):
                            parsed_results.append(f"Invalid result entry: {res}")
                            continue

                        metric = res.get("metric", {})
                        value = res.get("value")

                        if isinstance(value, (list, tuple)) and len(value) == 2:
                            metric_str = json.dumps(metric)
                            parsed_results.append(f"{metric_str} => {value[1]}")
                        else:
                            parsed_results.append(
                                f"{json.dumps(metric)} => Invalid value format: {value}"
                            )

                    return "Prometheus query results:\n" + "\\n".join(parsed_results)

            except aiohttp.ClientError as e:
                return f"Error querying Prometheus: {str(e)}"
            except Exception as e:
                return (
                    f"An unexpected error occurred while querying Prometheus: {str(e)}"
                )

    async def compare_metrics(self, query: str) -> str:
        metrics = re.findall(r"([a-zA-Z_:][a-zA-Z0-9_:]*)", query)
        if len(metrics) < 2:
            return "Please provide at least two metric names to compare."

        metric1, metric2 = metrics[:2]
        result1 = await self.query_prometheus(metric1)
        result2 = await self.query_prometheus(metric2)

        return f"Comparison between `{metric1}` and `{metric2}`:\\n\\nMetric 1 result:\\n{result1}\\n\\nMetric 2 result:\\n{result2}"

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
                if prom_query:
                    if self.valves.ENABLE_EMITTERS and __event_emitter__:
                        await __event_emitter__(
                            {
                                "type": "status",
                                "data": {
                                    "description": f"Extracted Prometheus query: {prom_query}",
                                    "done": False,
                                },
                            }
                        )
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
                else:
                    return {
                        "choices": [
                            {
                                "message": {
                                    "content": "Please provide a clear Prometheus query.",
                                    "role": "assistant",
                                },
                                "finish_reason": "stop",
                                "index": 0,
                            }
                        ]
                    }

            elif intention == "compare":
                result = await self.compare_metrics(query)
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
            else:
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