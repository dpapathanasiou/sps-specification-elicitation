# Tools

## [Alloy Evaluator](alloy_evaluator.py)

This tool uses the command line interface of the [Alloy latest release](https://github.com/AlloyTools/org.alloytools.alloy/releases#release-v6.2.0), in the form of the [org.alloytools.alloy.dist.jar](https://github.com/AlloyTools/org.alloytools.alloy/releases/download/v6.2.0/org.alloytools.alloy.dist.jar), which requires [Java 17](https://github.com/AlloyTools/org.alloytools.alloy?tab=readme-ov-file#tldr) to run.

## [RAG Tool](rag_tool.py)

This tool is driven by the [documents in the corpus](../corpus), the content of the [chosen prompt](../prompts/default.md), and the enviroment parameters used in the [RAGConfig](../rag_config.py) instance.

## [Version Database](version_db.py)

This tool logs history, in the form of Alloy source code, generated from the user/agent conversation. It uses [sqlite](https://sqlite.org/) as the backing store, as a [graph database](graph_database.py), inspired by [simple-graph](https://github.com/dpapathanasiou/simple-graph).
