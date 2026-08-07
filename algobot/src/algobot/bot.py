from os import getenv

from dotenv import load_dotenv
from smolagents import LiteLLMModel, ToolCallingAgent

from algobot.rag_config import RAGConfig
from algobot.rag_processor import rebuild_index
from algobot.tools.alloy_evaluator import evaluate_alloy_model
from algobot.tools.rag_tool import RAGTool
from algobot.tools.version_db import log_model_version

load_dotenv()  # read the .env file from this folder, if present

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
print(config)  # sanity check env
rebuild_index(config)

alloy_rag_tool = RAGTool(config=config)

evaluation = (
    f"'{evaluate_alloy_model.name}' (tool) -> {evaluate_alloy_model.description}"
)
version = f"'{log_model_version.name}' (tool) -> {log_model_version.description}"
max_retries_per_request = "10"

prompt = (
    f"{config.base_prompt}\n\n"
    f"<evaluation>{evaluation}</evaluation>\n"
    f"<version>{version}</version>\n"
    f"<retries>{max_retries_per_request}</retries>"
)

agent = ToolCallingAgent(
    tools=[evaluate_alloy_model, alloy_rag_tool, log_model_version],
    model=model,
    stream_outputs=True,
    instructions=prompt,
)


while True:
    user_input = input("Tell me about the system you want to build (/quit to stop) ")
    if user_input.lower() == "/quit":
        break
    response = agent.run(user_input)
    print(f"{response}")
