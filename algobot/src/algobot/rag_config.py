from pathlib import Path

from langchain_chroma import Chroma
from langchain_ollama import OllamaEmbeddings, OllamaLLM


class RAGConfig:
    def __init__(
        self,
        base_model,
        embed_model,
        corpus_dir,
        chroma_dir,
        base_prompt=None,
        **kwargs,
    ):
        self.base_model = base_model
        self.embed_model = embed_model
        self.corpus_dir = corpus_dir
        self.chroma_dir = chroma_dir
        self.__dict__.update(kwargs)

        self.corpus_path = Path(self.corpus_dir)
        if not self.corpus_path.exists():
            self.corpus_path.mkdir(parents=True, exist_ok=True)

        self.chroma_path = Path(self.chroma_dir)
        if not self.chroma_path.exists():
            self.chroma_path.mkdir(parents=True, exist_ok=True)

        self.collection_name = self.__dict__.get("collection_name", "local_corpus")

        self.vector_store = Chroma(
            collection_name=self.collection_name,
            embedding_function=self.get_embeddings(),
            persist_directory=self.chroma_dir,
        )
        self.retrieval_keys = self.__dict__.get("retrieval_keys", 4)
        self.retriever = self.vector_store.as_retriever(
            search_kwargs={"k": self.retrieval_keys}
        )

        self.chunk_size = self.__dict__.get("chunk_size", 800)
        self.chunk_overlap = self.__dict__.get("chunk_overlap", 100)

        if base_prompt is None:
            prompt_path = Path.cwd() / "prompts" / "default.md"
            self.base_prompt = prompt_path.read_text()
        else:
            prompt_path = Path(base_prompt)
            self.base_prompt = prompt_path.read_text()

    def get_base_model(self):
        return OllamaLLM(model=self.base_model)

    def get_embeddings(self):
        return OllamaEmbeddings(model=self.embed_model)

    def __str__(self):
        return f"RAGConfig:\n{''.join([f'\t{k} -> {v}\n' for k, v in self.__dict__.items()])}"
