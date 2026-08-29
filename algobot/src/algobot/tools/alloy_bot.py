import logging
from os import getenv

from dotenv import load_dotenv
from smolagents import LiteLLMModel, ToolCallingAgent

from algobot.tools.rag_config import RAGConfig
from algobot.tools.rag_processor import rebuild_index
from algobot.tools.rag_tool import RAGTool
from algobot.user_session import UserSession

_ = load_dotenv()  # read the .env file from this folder, if present


logger = logging.getLogger(__name__)


class AlloyBot:
    def __init__(self, show_config: bool = True, force_index_rebuild: bool = False):
        model = LiteLLMModel(
            model_id=getenv("SPS_BOT_MODEL", "ollama/qwen3.5:4b"),
            api_base=getenv("SPS_BOT_URL", "http://localhost:11434"),
            num_ctx=int(getenv("SPS_BOT_CONTEXT_SIZE", "8192")),
        )
        self.config = RAGConfig(
            base_model=getenv("SPS_RAG_MODEL", "gpt-oss"),
            embed_model=getenv("SPS_EMBED_MODEL", "embeddinggemma"),
            corpus_dir=getenv("SPS_CORPUS_DIR", "corpus"),
            chroma_dir=getenv("SPS_CHROMA_DIR", "chroma_db"),
        )
        if show_config:
            logger.info(self)
        rebuild_index(self.config, force=force_index_rebuild)

        alloy_rag_tool = RAGTool(config=self.config)

        prompt = f"{self.config.base_prompt}\n\n"
        self.agent = ToolCallingAgent(
            model=model,
            stream_outputs=True,
            planning_interval=3,
            instructions=prompt,
            tools=[alloy_rag_tool],
        )

    def model_alloy(self, cargo):
        if "user_input" not in cargo:
            raise RuntimeError("missing user input")

        session = cargo.get("session", UserSession())
        session.increment()
        cargo["session"] = session

        query = f"<user_input>{cargo['user_input']}</user_input>"
        if "prior_error" in cargo:
            query += f"\n<prior_error>{cargo['prior_error']}</prior_error>"
            if "alloy" in cargo:
                query += f"\n<prior_response>{cargo['alloy']}</prior_response>"

        response = self.agent.run(query)
        cargo["alloy"] = response
        return ("evaluate_alloy", cargo)

    def __str__(self):
        return str(self.config)
