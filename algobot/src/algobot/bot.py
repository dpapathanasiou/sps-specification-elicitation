from os import getenv

from dotenv import load_dotenv
from smolagents import CodeAgent, LiteLLMModel

load_dotenv()  # read the .env file from this folder, if present

model = LiteLLMModel(
    model_id=getenv("SPS_BOT_MODEL", "ollama/qwen3.5:4b"),
    api_base=getenv("SPS_BOT_URL", "http://localhost:11434"),
    num_ctx=int(getenv("SPS_BOT_CONTEXT_SIZE", "8192")),
)

agent = CodeAgent(
    tools=[],
    model=model,
)

while True:
    user_input = input("What's on your mind? (/quit to stop) ")
    if user_input.lower() == "/quit":
        break
    response = agent.run(user_input)
    print(f"{response}")
