import argparse
import logging

import gradio as gr

from algobot.workflow import Workflow

# make sure the bot responses, especially the visualizations,
# use the full width of the chat interface window
custom_css = """
[class*="bot"][class*="message"] {
    width: 99% !important;
    max-width: 99% !important;
}
"""

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

    workflow = Workflow()

    ui = gr.ChatInterface(
        workflow.run,
        chatbot=gr.Chatbot(scale=10, label="SPS Requirements Bot"),
        textbox=gr.Textbox(
            placeholder="Tell me about the system you want to build",
            container=False,
            scale=10,
        ),
        title="SPS Requirements Bot",
        description="Ask the SPS Requirements Bot to help you write a specification",
        fill_height=True,
        fill_width=True,
    )

    ui.launch(
        share=args.share_ui,
        css=custom_css,
        show_error=True,
        pwa=True,
        footer_links=["api", "settings"],
    )
