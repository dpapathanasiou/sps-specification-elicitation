import argparse
import logging

import gradio as gr

from algobot.gradio_utils import BOT_CSS
from algobot.tools.alloy_bot import AlloyBot
from algobot.workflow import Workflow

if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(levelname)s:%(name)s:%(message)s",
    )

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--show_config",
        help="print the agent configuration, including models and prompts used",
        type=bool,
        default=True,
    )
    parser.add_argument(
        "--force_index_rebuild",
        help="rebuild the corpus index, regardless of whether or not it already exists",
        type=bool,
        default=False,
    )
    parser.add_argument(
        "--share_ui",
        help="create a publicly accessible share link on Gradio's server",
        type=bool,
        default=False,
    )
    args = parser.parse_args()

    alloy = AlloyBot(
        show_config=args.show_config, force_index_rebuild=args.force_index_rebuild
    )
    workflow = Workflow(alloy.get_agent())

    def register_approval(like_data: gr.LikeData):
        # only allow up/down reactions on visualization results
        if any(
            isinstance(e, dict) and e.get("component") == "html"
            for e in like_data.value
        ):
            return list(workflow.vote(like_data.liked))

    with gr.Blocks() as ui:
        chatbot = gr.Chatbot(
            label="SPS Requirements Bot",
            scale=10,
            resizable=True,
            like_user_message=True,
        )
        chatbot.like(
            register_approval,
            inputs=None,
            outputs=chatbot,
        )

        gr.ChatInterface(
            workflow.run,
            chatbot=chatbot,
            textbox=gr.Textbox(
                placeholder="Tell me about the system you want to build",
                container=True,
                autofocus=True,
                scale=10,
            ),
            title="SPS Requirements Bot",
            description="Ask the SPS Requirements Bot to help you write a specification",
            fill_height=True,
            fill_width=True,
        )

    ui.launch(
        share=args.share_ui,
        css=BOT_CSS,
        show_error=True,
        pwa=True,
        footer_links=["api", "settings"],
    )
