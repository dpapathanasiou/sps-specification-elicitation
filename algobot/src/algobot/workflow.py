import logging
import random
from datetime import UTC
from datetime import datetime as dt
from pprint import pformat

from gradio import ChatMessage

from algobot.tools.alloy_bot import AlloyBot
from algobot.tools.alloy_evaluator import evaluate_alloy_model
from algobot.tools.alloy_visualizer import visualize_alloy_model
from algobot.tools.version_db import get_current_model_version, log_model_version
from algobot.user_session import UserSession

logger = logging.getLogger(__name__)


def prefix_timestamp(message, tag=None):
    if not tag:
        opening = ""
        closing = ""
    else:
        opening = f"<{tag}>"
        closing = f"</{tag}>"

    timestamp = dt.now(UTC).strftime("%H:%M")
    return f"{opening}({timestamp}) {message}{closing}"


def apologize():
    """A simple way of making the bot seem more 'human' when it gets the model syntax wrong"""

    mistakes = [
        "Sorry, I found an error, I'm going to rethink it, and try it again now",
        "Found an error in my approach, so I'll retry it",
        "There was a mistake with my original attempt, so I'm redoing it now",
        "Found a mistake, so I'll rework it and give it another shot",
        "Error in my code, so I'll retry with a new strategy",
        "Discovered an error, redoing it now",
    ]

    return random.choice(mistakes)


class Workflow:
    approved = "__yes__"
    rejected = "__no__"

    def __init__(self, retries=3):
        self.agent = AlloyBot()
        self.session = UserSession()
        self.retries = retries

    def run(self, message, history):
        logger.info(pformat(history))

        if message == self.approved:
            snapshot = get_current_model_version(self.session)

            ack = ""
            if snapshot and snapshot[0]["src"]:
                code = snapshot[0]["src"]
                ack += f"""Here is the model so far:\n\n```\n{code}\n```\n\n"""

            ack += "Please feel free to refine it further, if you wish (or, refresh the page to start over)"
            yield ChatMessage(ack)

        elif message == self.rejected:
            yield ChatMessage(
                "Please try explaining it again, from a different perspective, and I'm happy to take another stab at it  (or, refresh the page to start over)"
            )

        else:
            bot_msg = prefix_timestamp(
                "Ok, I'm on it! Let me try to find a solution for that"
            )
            response = ChatMessage(
                role="assistant",
                content=bot_msg,
                metadata={"title": "_Thinking_", "status": "pending"},
            )
            yield response

            alloy_code = self.agent.generate_model(message, session=self.session)

            bot_msg += prefix_timestamp(
                "I think I have a potential solution! Now, I need to make sure it is valid...",
                tag="p",
            )
            response.content = bot_msg
            response.metadata["title"] = "_Fingers crossed_"
            response.metadata["status"] = "pending"
            yield response

            visualization = None
            for _ in range(self.retries):
                (alloy_xml, alloy_err) = evaluate_alloy_model(alloy_code)
                if not alloy_err:
                    log_model_version(self.session, alloy_code, message)
                    visualization = visualize_alloy_model(alloy_xml)
                    break
                else:
                    bot_msg += prefix_timestamp(apologize(), tag="p")
                    response.content = bot_msg
                    response.metadata["title"] = "_Retrying_"
                    yield response

                    alloy_code = self.agent.generate_model(
                        message,
                        session=self.session,
                        prior_attempt=alloy_code,
                        prior_error=alloy_err,
                    )

            if visualization:
                yield ChatMessage(
                    content=visualization,
                    options=[
                        {"label": "Yes, that's correct", "value": self.approved},
                        {
                            "label": "No, that's not what I wanted",
                            "value": self.rejected,
                        },
                    ],
                )

            else:
                bot_msg += prefix_timestamp(
                    f"Alas, this agent could not find a solution found, even after {self.retries} attempts",
                    tag="p",
                )
                bot_msg += prefix_timestamp(
                    "Could you try again, perhaps describing it from a different perspective?",
                    tag="p",
                )
                bot_msg += "Refresh the page to start over"
                response.content = bot_msg
                response.metadata["status"] = "done"
                yield response
