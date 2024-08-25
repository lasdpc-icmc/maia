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

from utils.misc import get_last_user_message
from apps.webui.models.users import Users
from main import generate_chat_completions


class Pipe:
    class Valves(BaseModel):
        ROUTER_ID: str = Field(
            default="semantic-router",
            description="Identifier for the semantic router model.",
        )
        ROUTER_NAME: str = Field(
            default="Semantic Router", description="Name for the semantic router model."
        )
        INTENTION_MODEL: str = Field(
            default="llama3:latest",
            description="Model for determining intention.",
        )
        ENABLE_EMITTERS: bool = Field(
            default=True,
            description="Toggle to enable or disable event emitters.",
        )
        INTENTIONS: Dict[str, Dict[str, str]] = Field(
            default={
                "chatting": {
                    "description": "The user is simply chatting with you or no other intentions match the user request.",
                    "model": "llama3:latest",
                },
                "media": {
                    "description": "The user is specifically asking about an image or a video.",
                    "model": "llama3:latest",
                },
                "code": {
                    "description": "The user is asking about or requesting help with code.",
                    "model": "codeqwen:latest",
                },
            },
            description="Mapping of intentions to their descriptions and associated models.",
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
        if self.valves.ENABLE_EMITTERS and __event_emitter__ is not None:
            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": "Determining Intention and Routing Request to appropriate model",
                        "done": False,
                    },
                }
            )

        # Simple logic to determine intention without external API
        intentions_prompt = {
            k: v["description"] for k, v in self.valves.INTENTIONS.items()
        }

        intention_text = "chatting"

        if "image" in query.lower() or "video" in query.lower():
            intention_text = "media"
        elif "code" in query.lower() or "function" in query.lower():
            intention_text = "code"

        print(f"Raw intention text: {intention_text}")

        if self.valves.ENABLE_EMITTERS and __event_emitter__ is not None:
            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": f"Raw intention determined: {intention_text}",
                        "done": False,
                    },
                }
            )

        final_intention = (
            intention_text
        )

        model_id = self.valves.INTENTIONS[final_intention]["model"]

        if self.valves.ENABLE_EMITTERS and __event_emitter__ is not None:
            await __event_emitter__(
                {
                    "type": "status",
                    "data": {
                        "description": f"Query routed to model: {model_id}",
                        "done": False,
                    },
                }
            )

        return final_intention

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

            payload = {
                "model": model_id,
                "messages": messages,
                "stream": False,
            }

            print(f"Routing query to model: {model_id}")
            response = await generate_chat_completions(form_data=payload, user=user)

            print(
                f"Raw response from generate_chat_completions: {json.dumps(response, indent=2)}"
            )

            # Ensure the response is in the correct format
            if isinstance(response, dict) and "choices" in response:
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
            else:
                formatted_response = {
                    "choices": [
                        {
                            "message": {
                                "content": str(response),
                                "role": "assistant",
                            },
                            "finish_reason": "stop",
                            "index": 0,
                        }
                    ]
                }

            print(f"Formatted response: {json.dumps(formatted_response, indent=2)}")

            if self.valves.ENABLE_EMITTERS and __event_emitter__ is not None:
                await __event_emitter__(
                    {
                        "type": "status",
                        "data": {
                            "description": f"Model {model_id} has finished processing the request",
                            "done": True,
                        },
                    }
                )

            return formatted_response
        except Exception as e:
            print(f"Error in route_query: {str(e)}")
            if self.valves.ENABLE_EMITTERS and __event_emitter__ is not None:
                await __event_emitter__(
                    {
                        "type": "status",
                        "data": {
                            "description": f"Error occurred: {str(e)}",
                            "done": True,
                        },
                    }
                )
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

        # Extract only the content from the response
        if (
            isinstance(response, dict)
            and "choices" in response
            and len(response["choices"]) > 0
        ):
            content = response["choices"][0]["message"]["content"]
        else:
            content = "Error: Unexpected response format"

        print(f"Final content from pipe: {content}")

        return content  # Return only the content as a string