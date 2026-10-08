from pathlib import Path


class RAGConfig:
    def __init__(
        self,
        base_prompt=None,
        **kwargs,
    ):
        self.__dict__.update(kwargs)

        if base_prompt is None:
            prompt_path = Path.cwd() / "prompts" / "default.md"
            self.base_prompt = prompt_path.read_text()
        else:
            prompt_path = Path(base_prompt)
            self.base_prompt = prompt_path.read_text()

    def __str__(self):
        return f"RAGConfig:\n{''.join([f'\t{k} -> {v}\n' for k, v in self.__dict__.items()])}"
