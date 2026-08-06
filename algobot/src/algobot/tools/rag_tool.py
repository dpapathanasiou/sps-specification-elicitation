from smolagents.tools import Tool

from algobot.rag_config import RAGConfig


class RAGTool(Tool):
    name = "rag_tool"
    description = "Answers the given query using the corpus documents associated with the vector store, from the RAG configuration."
    inputs = {
        "query": {
            "type": "string",
            "description": "The query to perform. This should be semantically close to your target documents. Use the affirmative form rather than a question.",
        }
    }
    output_type = "string"

    def __init__(self, config: RAGConfig, **kwargs):
        super().__init__(**kwargs)
        self.config = config

    def forward(self, query: str) -> str:
        assert isinstance(query, str), "Your query must be a string"

        docs = self.config.vector_store.similarity_search(
            query, k=self.config.retrieval_keys
        )
        context = "".join(
            [
                f"\n\n===== Document {i!r} =====\n" + doc.page_content
                for i, doc in enumerate(docs)
            ]
        )
        return f"\n\n<context>{context}\n\n</context>\n"
