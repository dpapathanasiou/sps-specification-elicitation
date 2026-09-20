# Tools

## [Alloy Evaluator](alloy_evaluator.py)

This tool uses an [enhanced version](https://github.com/AlloyTools/org.alloytools.alloy/pull/351) of the Alloy command line interface: [build](https://github.com/AlloyTools/org.alloytools.alloy#tldr) that [PR branch](https://github.com/dpapathanasiou/org.alloytools.alloy/tree/enhanced-cli-metdata), and save the resulting jar file (org.alloytools.alloy.dist.jar) consistent with your local environment settings.

## [RAG Tool](rag_tool.py)

This tool is driven by the [documents in the corpus](../corpus), the content of the [chosen prompt](../prompts/default.md), and the enviroment parameters used in the [RAGConfig](rag_config.py) instance.

## [Version Database](version_db.py)

This tool logs history, in the form of Alloy source code, generated from the user/agent conversation. It uses [sqlite](https://sqlite.org/) as the backing store, as a [graph database](graph_database.py), inspired by [simple-graph](https://github.com/dpapathanasiou/simple-graph).
