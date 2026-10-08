import logging
from os import getenv

from dotenv import load_dotenv
from smolagents import LiteLLMModel, ToolCallingAgent

from algobot.tools.rag_config import RAGConfig
from algobot.tools.rag_processor import rebuild_index

_ = load_dotenv()  # read the .env file from this folder, if present


logger = logging.getLogger(__name__)


class AnthropicCompatibleLiteLLMModel(LiteLLMModel):
    def _prepare_completion_kwargs(self, *args, **kwargs):
        # Let smolagents build the default payload
        completion_kwargs = super()._prepare_completion_kwargs(*args, **kwargs)

        # Intercept and override tool_choice so Anthropic doesn't throw a 400
        if "tool_choice" in completion_kwargs:
            completion_kwargs["tool_choice"] = "auto"

        return completion_kwargs


class AlloyBot:
    def __init__(self, show_config: bool = True, force_index_rebuild: bool = False):

        # define the main model, based on env settings
        model_id = getenv("SPS_BOT_MODEL", "ollama/qwen3.5:4b")
        api_base = getenv("SPS_BOT_URL", "http://localhost:11434")
        model_api_key = getenv("SPS_BOT_MODEL_API_KEY")
        if not model_api_key:
            raise RuntimeError("SPS_BOT_MODEL_API_KEY required")

        model = AnthropicCompatibleLiteLLMModel(
            model_id=model_id,
            api_base=api_base,
            api_key=model_api_key,
        )

        # define the model config for the RAG processor (both models must be local Ollama)
        self.config = RAGConfig()
        if show_config:
            logger.info(self)
        rebuild_index(self.config, force=force_index_rebuild)

        prompt = f"{self.config.base_prompt}\n\n"
        self.agent = ToolCallingAgent(
            model=model,
            stream_outputs=True,
            planning_interval=3,
            instructions=prompt,
            tools=[],
        )

    def get_agent(self):
        return self.agent

    def __str__(self):
        return str(self.config)
