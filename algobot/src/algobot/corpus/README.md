# Corpus

This folder contains [retrieval-augmented generation (RAG)](https://en.wikipedia.org/wiki/Retrieval-augmented_generation) corpus material for the Alloy generator LLM.

## Examples of Alloy Models ([all-models.als](all-models.als))

Run [generate_model_examples.py](generate_model_examples.py) in the root of a clone of https://github.com/AlloyTools/models as follows:

```sh
$ python
>>> from generate_model_examples import concatenate_als_files
>>> concatenate_als_files(".", "./all-models.als")
```

## [Practical Alloy](https://practicalalloy.github.io/) (online book)

Content retrieved and combined into a single PDF file ([practicalalloy-github-io.pdf](practicalalloy-github-io.pdf)) using [site2pdf](https://github.com/laiso/site2pdf) and docker ([colima](https://colima.run/)):

```sh
cd ~/repos/repos-git/site2pdf
colima start
docker build --tag site2pdf --file Dockerfile .
docker run --name site2pdf site2pdf https://practicalalloy.github.io/
docker container cp site2pdf:/app/out/practicalalloy-github-io.pdf .
colima stop
```
