"""
gradio_utils.py

Cribbed from the smolagents GradioUI source
(https://github.com/huggingface/smolagents/blob/main/src/smolagents/gradio_ui.py),
these functions enable streaming from the agent LLM to the UI.

"""

import re
from collections.abc import Generator

import gradio as gr
from gradio.components.chatbot import MetadataDict
from smolagents.agent_types import AgentText
from smolagents.agents import PlanningStep
from smolagents.memory import ActionStep, FinalAnswerStep
from smolagents.models import MessageRole


def _get_step_footnote_content(
    step_log: ActionStep | PlanningStep, step_name: str
) -> str:
    """Get a footnote string for a step log with duration and token information"""
    step_footnote = f"**{step_name}**"
    if step_log.token_usage is not None:
        step_footnote += f" | Input tokens: {step_log.token_usage.input_tokens:,} | Output tokens: {step_log.token_usage.output_tokens:,}"
    step_footnote += (
        f" | Duration: {round(float(step_log.timing.duration), 2)}s"
        if step_log.timing.duration
        else ""
    )
    step_footnote_content = (
        f"""<span style="color: #bbbbc2; font-size: 12px;">{step_footnote}</span> """
    )
    return step_footnote_content


def _format_code_content(content: str) -> str:
    """
    Format code content as a code block if it's not already formatted.

    Args:
        content (`str`): Code content to format.

    Returns:
        `str`: Code content formatted as a code block.
    """
    content = content.strip()
    # Remove existing code blocks and end_code tags
    content = re.sub(r"```.*?\n", "", content)
    content = re.sub(r"\s*<end_code>\s*", "", content)
    content = content.strip()
    return f"<pre>\n{content}\n</pre>"


def _process_action_step(
    step_log: ActionStep, skip_model_outputs: bool = False
) -> Generator:
    """
    Process an [`ActionStep`] and yield appropriate Gradio ChatMessage objects.

    Args:
        step_log ([`ActionStep`]): ActionStep to process.
        skip_model_outputs (`bool`): Whether to skip model outputs.

    Yields:
        `gradio.ChatMessage`: Gradio ChatMessages representing the action step.
    """

    # Output the step number
    step_number = f"Step {step_log.step_number}"
    if not skip_model_outputs:
        yield gr.ChatMessage(
            role=MessageRole.ASSISTANT,
            content=f"**{step_number}**",
            metadata={"status": "done"},
        )

    # First yield the thought/reasoning from the LLM
    if not skip_model_outputs and getattr(step_log, "model_output", ""):
        yield gr.ChatMessage(
            role=MessageRole.ASSISTANT,
            content=step_log.model_output,
            metadata={"status": "done"},
        )

    # For tool calls, create a parent message
    if getattr(step_log, "tool_calls", []):
        first_tool_call = step_log.tool_calls[0]

        # Process arguments based on type
        args = first_tool_call.arguments
        if isinstance(args, dict):
            content = str(args.get("answer", str(args)))
        else:
            content = str(args).strip()

        # Create the tool call message
        parent_message_tool = gr.ChatMessage(
            role=MessageRole.ASSISTANT,
            content=content,
            metadata={
                "title": f"🛠️ Used tool {first_tool_call.name}",
                "status": "done",
            },
        )
        yield parent_message_tool

    # Display execution logs if they exist
    if getattr(step_log, "observations", "") and step_log.observations.strip():
        log_content = step_log.observations.strip()
        if log_content:
            log_content = re.sub(r"^Execution logs:\s*", "", log_content)
            yield gr.ChatMessage(
                role=MessageRole.ASSISTANT,
                content=f"```bash\n{log_content}\n",
                metadata={"title": "📝 Execution Logs", "status": "done"},
            )

    # Handle errors
    if getattr(step_log, "error", None):
        yield gr.ChatMessage(
            role=MessageRole.ASSISTANT,
            content=str(step_log.error),
            metadata={"title": "💥 Error", "status": "done"},
        )

    # Add step footnote and separator
    yield gr.ChatMessage(
        role=MessageRole.ASSISTANT,
        content=_get_step_footnote_content(step_log, step_number),
        metadata={"status": "done"},
    )
    yield gr.ChatMessage(
        role=MessageRole.ASSISTANT, content="-----", metadata={"status": "done"}
    )


def _process_planning_step(
    step_log: PlanningStep, skip_model_outputs: bool = False
) -> Generator:
    """
    Process a [`PlanningStep`] and yield appropriate gradio.ChatMessage objects.

    Args:
        step_log ([`PlanningStep`]): PlanningStep to process.

    Yields:
        `gradio.ChatMessage`: Gradio ChatMessages representing the planning step.
    """

    title = "🤔 _Thinking_"
    if not skip_model_outputs:
        yield gr.ChatMessage(
            role=MessageRole.ASSISTANT,
            content="**Planning step**",
            metadata={"title": title, "status": "done"},
        )
        yield gr.ChatMessage(
            role=MessageRole.ASSISTANT,
            content=step_log.plan,
            metadata={"title": title, "status": "done"},
        )
    yield gr.ChatMessage(
        role=MessageRole.ASSISTANT,
        content=_get_step_footnote_content(step_log, "Planning step"),
        metadata={"title": title, "status": "done"},
    )
    yield gr.ChatMessage(
        role=MessageRole.ASSISTANT,
        content="-----",
        metadata={"title": title, "status": "done"},
    )


def _process_final_answer_step(step_log: FinalAnswerStep) -> Generator:
    """
    Process a [`FinalAnswerStep`] and yield appropriate gradio.ChatMessage objects.

    Args:
        step_log ([`FinalAnswerStep`]): FinalAnswerStep to process.

    Yields:
        `gradio.ChatMessage`: Gradio ChatMessages representing the final answer.
    """

    final_answer = step_log.output
    if isinstance(final_answer, AgentText):
        yield gr.ChatMessage(
            role=MessageRole.ASSISTANT,
            content=f"**Final answer:**\n{final_answer.to_string()}\n",
            metadata={"status": "done"},
        )
    else:
        yield gr.ChatMessage(
            role=MessageRole.ASSISTANT,
            content=f"**Final answer:** {final_answer!r}",
            metadata={"status": "done"},
        )


def as_chat_message(content, is_code=False, status=None, title=None) -> Generator:
    """
    Produce a gr.ChatMessage instance with the given content, and optional status and title metadata.
    """

    if is_code:
        content = _format_code_content(content)

    metadata = MetadataDict()

    if status is None:
        status = "done"
    metadata["status"] = status

    if title:
        metadata["title"] = title

    yield gr.ChatMessage(
        role=MessageRole.ASSISTANT,
        content=content,
        metadata=metadata,
    )


def pull_messages_from_step(
    step_log: ActionStep | PlanningStep | FinalAnswerStep,
    skip_model_outputs: bool = False,
):
    """Extract Gradio ChatMessage objects from agent steps with proper nesting.

    Args:
        step_log: The step log to display as gr.ChatMessage objects.
        skip_model_outputs: If True, skip the model outputs when creating the gr.ChatMessage objects:
            This is used for instance when streaming model outputs have already been displayed.
    """

    if isinstance(step_log, ActionStep):
        yield from _process_action_step(step_log, skip_model_outputs)
    elif isinstance(step_log, PlanningStep):
        yield from _process_planning_step(step_log, skip_model_outputs)
    elif isinstance(step_log, FinalAnswerStep):
        yield from _process_final_answer_step(step_log)


__all__ = ["as_chat_message", "pull_messages_from_step"]
