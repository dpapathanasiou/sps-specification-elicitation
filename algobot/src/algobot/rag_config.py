from os import getenv
from pathlib import Path

from langchain_chroma import Chroma
from langchain_ollama import OllamaEmbeddings, OllamaLLM


class RAGConfig:
    def __init__(
        self,
        chunk_size=None,
        chunk_overlap=None,
        collection_name=None,
        retrieval_keys=None,
        base_prompt=None,
    ):
        self.base_model = getenv("SPS_RAG_MODEL", "gpt-oss")
        self.embed_model = getenv("SPS_EMBED_MODEL", "embeddinggemma")

        self.corpus_path = Path(getenv("SPS_CORPUS_DIR", "corpus"))
        if not self.corpus_path.exists():
            self.corpus_path.mkdir(parents=True, exist_ok=True)

        self.chroma_dir = getenv("SPS_CHROMA_DIR", "chroma_db")
        self.chroma_path = Path(self.chroma_dir)
        if not self.chroma_path.exists():
            self.chroma_path.mkdir(parents=True, exist_ok=True)

        self.collection_name = (
            "local_corpus" if collection_name is None else collection_name
        )
        self.vector_store = Chroma(
            collection_name=self.collection_name,
            embedding_function=self.get_embeddings(),
            persist_directory=self.chroma_dir,
        )
        self.retrieval_keys = 4 if retrieval_keys is None else retrieval_keys
        self.retriever = self.vector_store.as_retriever(
            search_kwargs={"k": self.retrieval_keys}
        )

        self.chunk_size = 800 if chunk_size is None else chunk_size
        self.chunk_overlap = 100 if chunk_overlap is None else chunk_overlap

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
        return f"""RAGConfig:
        CORPUS_DIR\t= {self.corpus_path.name}
        CHROMA_DIR\t= {self.chroma_path.name}

        Base Model\t= {self.base_model}
        Embed Model\t= {self.embed_model}

        chunk_size\t= {self.chunk_size}
        chunk_overlap\t= {self.chunk_overlap}
        collection_name\t= {self.collection_name}
        retrieval_keys\t= {self.retrieval_keys}

        base_prompt\t= `{self.base_prompt[:50]}` ...
        """
