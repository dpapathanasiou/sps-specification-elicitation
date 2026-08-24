from typing import Generator

from smolagents import GradioUI
from smolagents.agents import MultiStepAgent, PlanningStep, ToolOutput
from smolagents.gradio_ui import pull_messages_from_step
from smolagents.memory import ActionStep, FinalAnswerStep
from smolagents.models import (
    ChatMessageStreamDelta,
    agglomerate_stream_deltas,
)


class EnhancedGradioUI(GradioUI):
    """Enhanced GradioUI that allows custom HTML components
    (https://gradio.app/guides/custom-HTML-components) to render properly.

    Extends smolagents.GradioUI
    (https://github.com/huggingface/smolagents/blob/main/src/smolagents/gradio_ui.py)
    with one minor modification, to check explicitly for
    `gr.components.html.HTML` in the event stream.
    """

    def __init__(
        self,
        agent: MultiStepAgent,
        file_upload_folder: str = None,
        reset_agent_memory: bool = False,
    ):
        super().__init__(agent, file_upload_folder, reset_agent_memory)

    def _stream_response(self, message: str | dict, history: list[dict]) -> Generator:
        """Stream agent responses for ChatInterface."""
        import gradio as gr

        task, task_files = self._process_message(message)

        all_messages: list[gr.ChatMessage] = []
        accumulated_events: list[ChatMessageStreamDelta] = []
        streaming_msg_idx: int | None = None

        for event in self.agent.run(
            task,
            images=task_files,
            stream=True,
            reset=self.reset_agent_memory,
            additional_args=None,
        ):
            # This is the enhancement: generate a gr.ChatMessage from the HTML component
            if isinstance(event, ToolOutput) and isinstance(
                event.output, gr.components.html.HTML
            ):
                all_messages.append(
                    gr.ChatMessage(
                        content=event.output,
                    )
                )
                continue

            if isinstance(event, ActionStep | PlanningStep | FinalAnswerStep):
                # Remove streaming message if present
                if streaming_msg_idx is not None:
                    all_messages.pop(streaming_msg_idx)
                    streaming_msg_idx = None

                for msg in pull_messages_from_step(
                    event,
                    skip_model_outputs=getattr(self.agent, "stream_outputs", False),
                ):
                    all_messages.append(
                        gr.ChatMessage(
                            role=msg.role,
                            content=msg.content,
                            metadata=msg.metadata,
                        )
                    )
                    yield all_messages
                accumulated_events = []
            elif isinstance(event, ChatMessageStreamDelta):
                accumulated_events.append(event)
                text = agglomerate_stream_deltas(
                    accumulated_events
                ).render_as_markdown()
                text = text.replace("<", r"\<").replace(">", r"\>")
                msg = gr.ChatMessage(role="assistant", content=text)
                if streaming_msg_idx is None:
                    streaming_msg_idx = len(all_messages)
                    all_messages.append(msg)
                else:
                    all_messages[streaming_msg_idx] = msg
                yield all_messages
