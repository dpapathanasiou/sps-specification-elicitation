import argparse
from os import getenv

from dotenv import load_dotenv
from smolagents import GradioUI, LiteLLMModel, ToolCallingAgent

from algobot.rag_config import RAGConfig
from algobot.rag_processor import rebuild_index
from algobot.tools.alloy_evaluator import evaluate_alloy_model
from algobot.tools.alloy_visualizer import visualize_alloy_model
from algobot.tools.rag_tool import RAGTool
from algobot.tools.version_db import log_model_version


def initialize(
    show_config: bool = True, force_index_rebuild: bool = False
) -> ToolCallingAgent:
    """
    Initialize the agent, based on the env and other settings.
    """

    _ = load_dotenv()  # read the .env file from this folder, if present

    model = LiteLLMModel(
        model_id=getenv("SPS_BOT_MODEL", "ollama/qwen3.5:4b"),
        api_base=getenv("SPS_BOT_URL", "http://localhost:11434"),
        num_ctx=int(getenv("SPS_BOT_CONTEXT_SIZE", "8192")),
    )

    config = RAGConfig(
        base_model=getenv("SPS_RAG_MODEL", "gpt-oss"),
        embed_model=getenv("SPS_EMBED_MODEL", "embeddinggemma"),
        corpus_dir=getenv("SPS_CORPUS_DIR", "corpus"),
        chroma_dir=getenv("SPS_CHROMA_DIR", "chroma_db"),
    )
    if show_config:
        print(config)  # sanity check env
    rebuild_index(config, force=force_index_rebuild)

    alloy_rag_tool = RAGTool(config=config)
    evaluation = (
        f"'{evaluate_alloy_model.name}' (tool) -> {evaluate_alloy_model.description}"
    )
    visualization = (
        f"'{visualize_alloy_model.name}' (tool) -> {visualize_alloy_model.description}"
    )
    version = f"'{log_model_version.name}' (tool) -> {log_model_version.description}"
    max_retries_per_request = "10"

    prompt = (
        f"{config.base_prompt}\n\n"
        f"<evaluation>{evaluation}</evaluation>\n"
        f"<visualization>{visualization}</visualization>\n"
        f"<version>{version}</version>\n"
        f"<retries>{max_retries_per_request}</retries>"
    )
    agent = ToolCallingAgent(
        tools=[
            evaluate_alloy_model,
            alloy_rag_tool,
            visualize_alloy_model,
            log_model_version,
        ],
        model=model,
        stream_outputs=True,
        instructions=prompt,
    )

    return agent


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--cli", help="use the command line interface", type=bool, default=False
    )
    group.add_argument(
        "--ui", help="use the Gradio local user interface", type=bool, default=True
    )
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
        help="create a publicly accessible share link on Gradio's server (applied only when --ui=True)",
        type=bool,
        default=False,
    )
    args = parser.parse_args()
    agent = initialize(
        show_config=args.show_config, force_index_rebuild=args.force_index_rebuild
    )
    opening_msg = "Tell me about the system you want to build"
    if args.cli:
        while True:
            user_input = input(f"{opening_msg} (/quit to stop) ")
            if user_input.lower() == "/quit":
                break
            response = agent.run(user_input)
            print(f"{response}")
    elif args.ui:
        ui = GradioUI(agent=agent)
        ui.name = opening_msg
        ui.launch(
            share=args.share_ui,
            show_error=True,
            pwa=True,
            footer_links=["api", "settings"],
        )
