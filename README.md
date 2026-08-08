# About

Code, data, and notes related to my [The Secure Program Synthesis Fellowship](https://apartresearch.com/fellowships/the-secure-program-synthesis-fellowship) project.

## Quickstart

### Prerequisites

Clone this repo, and perform these one-time setups:

- Install [uv](https://docs.astral.sh/uv/getting-started/installation/)
- Install [Ollama](https://ollama.com/download)
- [Alloy](https://alloytools.org/)
  - Download [org.alloytools.alloy.dist.jar](https://github.com/AlloyTools/org.alloytools.alloy/releases/download/v6.2.0/org.alloytools.alloy.dist.jar) from the [latest release (v6.2.0)](https://github.com/AlloyTools/org.alloytools.alloy/releases) and note the folder location
  - Requires [Java JRE 17](https://github.com/AlloyTools/org.alloytools.alloy?tab=readme-ov-file#tldr) - available via [SDKMAN!](https://sdkman.io/)

### Running

1. Choose which [Ollama model](https://ollama.com/search) to use, and run it:

   ```sh
   ollama run llama3.2
   ```

1. Define the required environment variables (can also save these to a `.env` file in the `~/path/to/sps-specification-elicitation/algobot/src/algobot` folder, which is not tracked by source control):

   ```sh
   SPS_BOT_MODEL = "ollama/llama3.2"
   SPS_BOT_CONTEXT_SIZE = 32768
   SPS_BOT_URL = "http://localhost:11434"
   SPS_RAG_MODEL = "llama3.2"
   SPS_EMBED_MODEL = "embeddinggemma:latest"
   SPS_CORPUS_DIR = "corpus"
   SPS_CHROMA_DIR = "chroma_db"
   SPS_ALLOY_JAR = "/usr/local/alloy/org.alloytools.alloy.dist.jar" # or where downloaded jar was saved
   ```

1. Activate the uv environment, and run the bot:
   ```sh
   cd ~/path/to/sps-specification-elicitation/
   cd algobot
   source .venv/bin/activate
   cd src/algobot
   uv run bot.py
   ```
