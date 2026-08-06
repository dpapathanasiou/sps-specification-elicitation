from smolagents.tools import tool

from algobot.rag_config import RAGConfig


@tool
def answer_with_rag_context(config: RAGConfig, question: str) -> str:
    """Answers the given question with the corpus documents associated with the associated RAG configuration.

    Args:
        config: The RAG configuration, which has the docs and prompt defined
        question: The user's input, as a natural language string

    Returns:
        str: An Alloy model, based on the user user's question, and the config docs and prompt.
    """

    docs = config.retriever.invoke(question)

    context = "\n\n".join([doc.page_content for doc in docs])

    prompt = f"{config.base_prompt}\n\n<context>\n{context}</context>\n\n<question>{question}</question>"

    return config.get_base_model().invoke(prompt).strip()
