from os import getenv

from dotenv import load_dotenv
from smolagents import LiteLLMModel, ToolCallingAgent

from algobot.rag_config import RAGConfig
from algobot.rag_processor import rebuild_index
from algobot.tools.alloy_evaluator import evaluate_alloy_model
from algobot.tools.rag_tool import answer_with_rag_context

load_dotenv()  # read the .env file from this folder, if present

model = LiteLLMModel(
    model_id=getenv("SPS_BOT_MODEL", "ollama/qwen3.5:4b"),
    api_base=getenv("SPS_BOT_URL", "http://localhost:11434"),
    num_ctx=int(getenv("SPS_BOT_CONTEXT_SIZE", "8192")),
)


config = RAGConfig()
print(config)
rebuild_index(config)


agent = ToolCallingAgent(
    tools=[evaluate_alloy_model, answer_with_rag_context],
    model=model,
)

# TODO: loop along these lines
# https://huggingface.co/docs/smolagents/main/en/conceptual_guides/intro_agents#an-introduction-to-agentic-systems

while True:
    user_input = input("What's on your mind? (/quit to stop) ")
    if user_input.lower() == "/quit":
        break
    response = agent.run(user_input)
    print(f"{response}")
