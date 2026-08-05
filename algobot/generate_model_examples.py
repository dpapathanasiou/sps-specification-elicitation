import os
import subprocess
from datetime import datetime

"""
Run this script in the root of a clone of https://github.com/AlloyTools/models as follows:

>>> from generate_model_examples import concatenate_als_files
>>> concatenate_als_files(".", "./all-models.als")

"""


def get_git_hash():
    try:
        return (
            subprocess.check_output(["git", "rev-parse", "HEAD"])
            .decode("utf-8")
            .strip()
        )
    except subprocess.CalledProcessError:
        return "unknown"


def concatenate_als_files(root_dir, output_file):
    contents = []

    for dirpath, _, filenames in os.walk(root_dir, topdown=True):
        for filename in sorted(filenames):
            if filename.endswith(".als"):
                filepath = os.path.join(dirpath, filename)
                try:
                    relpath = os.path.relpath(filepath, root_dir)
                    with open(filepath, "r", encoding="utf-8") as f:
                        file_content = f.read()
                        contents.append(f"// Model: {relpath}\n{file_content}")
                except OSError as e:
                    print(f"Could not read {filepath}: {e}")

    result = "\n".join(contents)

    rfc_date = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    git_hash = get_git_hash()
    header = f"// Generated {rfc_date}\n// from https://github.com/AlloyTools/models/\n// at commit {git_hash}"

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(header + "\n\n" + result)
