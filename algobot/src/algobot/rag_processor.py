from collections import defaultdict
from pathlib import Path

from langchain_community.document_loaders import (
    BSHTMLLoader,
    PyPDFLoader,
    TextLoader,
    UnstructuredMarkdownLoader,
)
from langchain_community.document_loaders.generic import GenericLoader
from langchain_community.document_loaders.parsers import LanguageParser
from langchain_text_splitters import Language, RecursiveCharacterTextSplitter

from algobot.rag_config import RAGConfig

ALLOY_SOURCE = [".als"]

TEXT = [".pdf", ".css", ".htm", ".html", ".md", ".txt", ".text"] + ALLOY_SOURCE

SOURCE_CODE = {
    ".c": Language.C,
    ".h": Language.C,
    ".cbl": Language.COBOL,
    ".cob": Language.COBOL,
    ".cpy": Language.COBOL,
    ".cs": Language.CSHARP,
    ".cpp": Language.CPP,
    ".ex": Language.ELIXIR,
    ".exs": Language.ELIXIR,
    ".go": Language.GO,
    ".hs": Language.HASKELL,
    ".java": Language.JAVA,
    ".js": Language.JS,
    ".jsx": Language.JS,
    ".json": Language.JS,
    ".kt": Language.KOTLIN,
    ".lua": Language.LUA,
    ".php": Language.PHP,
    ".pl": Language.PERL,
    ".py": Language.PYTHON,
    ".r": Language.R,
    ".rst": Language.RST,
    ".rb": Language.RUBY,
    ".rs": Language.RUST,
    ".scala": Language.SCALA,
    ".swift": Language.SWIFT,
    ".tex": Language.LATEX,
    ".latex": Language.LATEX,
    ".ts": Language.TS,
    ".tsx": Language.TS,
}


def load_corpus(corpus_folder: Path):
    docs = defaultdict(list)  # k=file extension, v=list of loaded docs
    corpus_files = []

    for p in corpus_folder.glob("**/*"):
        file_ext = p.suffix.lower()
        if file_ext in SOURCE_CODE:
            corpus_files.append(f" - {p.name}")
            docs[file_ext].extend(
                GenericLoader.from_filesystem(p, parser=LanguageParser()).load()
            )
        elif file_ext in TEXT:
            corpus_files.append(f" - {p.name}")
            match file_ext:
                case ".pdf":
                    docs[file_ext].extend(PyPDFLoader(p).load())
                case ".css" | ".htm" | ".html":
                    docs[file_ext].extend(BSHTMLLoader(p).load())
                case ".md":
                    docs[file_ext].extend(UnstructuredMarkdownLoader(p).load())
                case _:
                    docs[file_ext].extend(
                        TextLoader(p, autodetect_encoding=True).load()
                    )
    print(f"Corpus files:\n{chr(10).join(corpus_files)}\n")

    return dict(docs)


def rebuild_index(config: RAGConfig, force=False):
    vector_store = config.vector_store

    index = vector_store.get()
    if not force and index["ids"]:
        print("Corpus already exists and is not empty, skipping rebuild")
        return

    vector_store.reset_collection()

    docs_by_language = load_corpus(config.corpus_path)
    for extension, docs in docs_by_language.items():
        if extension in SOURCE_CODE:
            language = SOURCE_CODE[extension]
            print(f"- indexing {len(docs)} docs for {language} ({extension})")
            splitter = RecursiveCharacterTextSplitter.from_language(
                language=SOURCE_CODE[extension],
                chunk_size=config.chunk_size,
                chunk_overlap=0,  # ovelapping programming source code is confusing
                add_start_index=True,
            )
            data = splitter.split_documents(docs)
            vector_store.add_documents(data)
        elif extension in TEXT:
            print(f"- indexing {len(docs)} docs as text ({extension})")
            splitter = RecursiveCharacterTextSplitter(
                chunk_size=config.chunk_size,
                chunk_overlap=0 if extension in ALLOY_SOURCE else config.chunk_overlap,
                add_start_index=True,
            )
            data = splitter.split_documents(docs)
            vector_store.add_documents(data)
