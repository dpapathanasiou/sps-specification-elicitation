"""
version_formatter.py

Functions to transform the model version json objects stored in the
version database into more human friendly versions, both as pseudo
json strings and markdown blocks.

"""

import json
import textwrap
from datetime import UTC
from datetime import datetime as dt
from email.utils import format_datetime

KEY_LABELS = {  # original key: human-friendly label
    "src": "Alloy Model",
    "user_input": "Requirements",
    "ts": "Timestamp",
    "evaluation": "Model Evaluation Results",
}

MULTILINE_KEYS = ("src", "user_input")

MD_SECTIONS = (  # (original key, heading level), in display order
    ("user_input", 3),
    ("src", 3),
    ("ts", 4),
    ("evaluation", 4),
)

MD_FENCES = {  # original key: code fence language
    "src": "alloy",
    "evaluation": "json",
}


def to_rfc2822(ts: float) -> str:
    """Convert the timestamp float into a RFC 2822 string"""

    return format_datetime(dt.fromtimestamp(ts, tz=UTC), usegmt=True)


def relabel_keys(d: dict, labels: dict[str, str] = KEY_LABELS) -> dict:
    """Produce a new dict, replacing the old keys for the new ones"""

    return {labels.get(key, key): value for key, value in d.items()}


def format_version(
    version: dict,
    multiline_keys: tuple[str, ...] = MULTILINE_KEYS,
    indent: int = 4,
) -> str:
    """
    Reformat the model version object into a more accessible json-like
    format, expanding multiline values in particular.
    """

    placeholders: dict[str, str] = {}
    patched = dict(version)

    for key in multiline_keys:
        value = version.get(key)
        if isinstance(value, str) and "\n" in value:
            placeholder = f"__MULTILINE_PLACEHOLDER_{key}__"
            placeholders[placeholder] = value
            patched[key] = placeholder

    if isinstance(version.get("ts"), (int, float)):
        patched["ts"] = to_rfc2822(version["ts"])

    patched = relabel_keys(patched)

    text = json.dumps(patched, indent=indent)

    for placeholder, value in placeholders.items():
        body = textwrap.indent(value.rstrip("\n"), " " * (indent * 2))
        block = f'"""\n{body}\n{" " * indent}"""'
        text = text.replace(f'"{placeholder}"', block, 1)

    return text


def format_version_md(
    version: dict,
    sections: tuple[tuple[str, int], ...] = MD_SECTIONS,
    labels: dict[str, str] = KEY_LABELS,
    fences: dict[str, str] = MD_FENCES,
) -> str:
    """
    Reformat the model version object into a markdown block, giving
    multiline values in particular their own fenced sections.

    """

    parts: list[str] = []

    for key, level in sections:
        value = version.get(key)
        if value is None:
            continue

        if key == "ts" and isinstance(value, (int, float)):
            value = to_rfc2822(value)
        elif not isinstance(value, str):
            value = json.dumps(value, indent=4)

        value = value.strip()
        if key in fences:
            value = f"```{fences[key]}\n{value}\n```"

        heading = f"{'#' * level} {labels.get(key, key)}"
        parts.append(f"{heading}\n{value}")

    return "\n\n".join(parts)
