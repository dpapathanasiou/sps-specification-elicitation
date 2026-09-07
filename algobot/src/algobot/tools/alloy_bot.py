import logging
from os import getenv

from dotenv import load_dotenv
from smolagents import LiteLLMModel, ToolCallingAgent

from algobot.tools.rag_config import RAGConfig
from algobot.tools.rag_processor import rebuild_index
from algobot.tools.rag_tool import RAGTool

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

    def generate_model(self, user_input, session, prior_attempt=None, prior_error=None):
        session.increment()

        query = f"<user_input>{user_input}</user_input>"
        if prior_error:
            query += f"\n<prior_error>{prior_error}</prior_error>"

        if prior_attempt:
            query += f"\n<prior_attempt>{prior_attempt}</prior_attempt>"

        return self.agent.run(query)

    def __str__(self):
        return str(self.config)
