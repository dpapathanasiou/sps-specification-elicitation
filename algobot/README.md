# About

This is the source and data for the app which serves as the main point of coordination between the human user and the various agents and tools.

# Initial Setup

## Activate the virtual environment:

```sh
source .venv/bin/activate
```

## Dependencies

*Only needed if ever want to recreate from scratch, without using the current [uv.lock](uv.lock)* - create a [uv project](https://docs.astral.sh/uv/#project-structure) as follows:

```sh
uv init --library --python 3.14
uv add uv add 'smolagents[toolkit,litellm,mcp,telemetry,gradio,docker]' \
  langchain \
  langchain-core \
  langchain-community \
  langchain-ollama \
  langchain-text-splitters \
  langchain-chroma \
  chromadb \
  sentence-transformers \
  pypdf \
  beautifulsoup4
```
