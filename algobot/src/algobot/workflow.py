import json
import logging
import random
from collections.abc import Generator

from smolagents.agents import PlanningStep
from smolagents.memory import ActionStep, FinalAnswerStep
from smolagents.models import (
    ChatMessageStreamDelta,
    agglomerate_stream_deltas,
)

from algobot.gradio_utils import as_chat_message, pull_messages_from_step
from algobot.tools.alloy_evaluator import evaluate_alloy_model, partition_metadata
from algobot.tools.alloy_visualizer import visualize_alloy_model
from algobot.tools.version_db import get_current_model_version, log_model_version
from algobot.user_session import UserSession

logger = logging.getLogger(__name__)


def apologize():
    """A simple way of making the bot seem more 'human' when it gets the model syntax wrong"""

    mistakes = [
        "Sorry, I found an error, I'm going to rethink it, and try it again now.",
        "There was an error, so I'm going to retry it.",
        "There was a mistake with my original attempt, so I'm redoing it now.",
        "I found a mistake, so I'll give it another shot right now.",
        "There's an error, so I'll redo it, with a new approach.",
    ]

    return random.choice(mistakes)


class Workflow:
    def __init__(self, agent, retries=3):
        self.agent = agent
        self.retries = retries
        self.session = UserSession()
        self.alloy = {}

    def generate_alloy_code(
        self,
        task: str,
        task_images: list | None = None,
        additional_args: dict | None = None,
    ) -> Generator:
        """Run the agent to see if it can generate an Alloy model corresponding to the task (user input) given."""

        accumulated_events: list[ChatMessageStreamDelta] = []

        alloy_code = None
        for event in self.agent.run(
            task,
            images=task_images,
            stream=True,
            reset=False,
            additional_args=additional_args,
        ):
            if isinstance(event, ActionStep | PlanningStep | FinalAnswerStep):
                if isinstance(event, FinalAnswerStep):
                    alloy_code = event.output
                yield from pull_messages_from_step(
                    event,
                    # If we're streaming model outputs, no need to display them twice
                    skip_model_outputs=getattr(self.agent, "stream_outputs", False),
                )
                accumulated_events = []
            elif isinstance(event, ChatMessageStreamDelta):
                accumulated_events.append(event)
                text = agglomerate_stream_deltas(
                    accumulated_events
                ).render_as_markdown()
                yield text

        if alloy_code:
            self.alloy["code"] = alloy_code

        self.session.increment()

    def stream_to_ui(
        self,
        task: str,
        task_images: list | None = None,
        additional_args: dict | None = None,
    ) -> Generator:
        """Execute the workflow, taking up to {self.retries} times to see if the agent can produce a valid Alloy model."""

        if additional_args is None:
            additional_args = {}

        visualization = None
        for _ in range(self.retries):
            yield from self.generate_alloy_code(task, task_images, additional_args)
            if "code" not in self.alloy:
                yield from as_chat_message(
                    "Sorry, I could not produce a result from that description."
                )
                break

            alloy_code = self.alloy["code"]
            yield from as_chat_message(
                "I think I have a potential solution! Now, I need to make sure it is valid...",
                title="🤞 _Possible solution found_",
                status="pending",
            )

            (alloy_xml, alloy_err, alloy_log) = evaluate_alloy_model(alloy_code)
            if alloy_err:
                # invalid, unfortunately, so pass those details back to the agent
                yield from as_chat_message(apologize())
                additional_args["prior_attempt"] = alloy_code
                additional_args["prior_error"] = alloy_err
            else:
                # valid syntactically, so visualize and seek user approval
                log_model_version(self.session, alloy_code, task, alloy_log)

                title = None
                (info, warn) = partition_metadata(alloy_log)
                if info:
                    self.alloy["info"] = [x["message"] for x in info if "message" in x]
                    title = "✅ " + " ".join(self.alloy["info"])
                if warn:
                    self.alloy["warn"] = [x["message"] for x in warn if "message" in x]
                    title = "❌ " + " ".join(self.alloy["warn"])

                visualization = visualize_alloy_model(alloy_xml)
                yield from as_chat_message(visualization, title=title)
                break

        if visualization is None:
            yield from as_chat_message(
                "Unfortunately, I need more to work with. Can you explain it differently?"
            )

    def vote(self, approved):
        """Respond to the user's thumbs up/down on the visualization."""

        if approved:
            yield from as_chat_message(
                "Here's the corresponding Alloy model. Please feel free to refine it further if you wish, or, refresh the page to start over."
            )

            results = "\n".join(
                [
                    json.dumps(version, indent=4)
                    for version in get_current_model_version(self.session)
                ]
            )
            yield from as_chat_message(results, is_code=True)

        else:
            yield from as_chat_message(
                "Let's try again. What should we edit or update? Please tell me more."
            )

    def run(self, message, history):
        additional_args = {}
        if history:
            additional_args["history"] = history[-1]

        yield from self.stream_to_ui(message, additional_args=additional_args)
