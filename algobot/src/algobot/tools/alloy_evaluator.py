import json
import logging
import re
import subprocess
import tempfile
from os import getenv
from pathlib import Path

from dotenv import load_dotenv

_ = load_dotenv()  # read the .env file, if present


logger = logging.getLogger(__name__)

INFO_PATTERN = re.compile(r"^\[main\] INFO (.*) - (.*)$")


def is_info_line_match(logline):
    """Apply the info logline regex pattern and return whether or not it's a match"""

    return INFO_PATTERN.match(logline)


def parse_info_json(logline):
    """Parse and return the json metadata in the logline (if it exists)"""

    match = is_info_line_match(logline)
    if match:
        try:
            return json.loads(match.group(2))
        except json.JSONDecodeError:
            pass


def partition_metadata(metadata):
    """Partition the list of json metadata into (valid, invalid) lists"""

    valid = []
    invalid = []

    for m in metadata:
        if "valid" in m:
            if m["valid"]:
                valid.append(m)
            else:
                invalid.append(m)

    return (valid, invalid)


def evaluate_alloy_model(alloy_source):
    logger.info(f"evaluate_alloy_model -> {alloy_source}")

    alloy_jar = Path(
        getenv("SPS_ALLOY_JAR", "/usr/local/alloy/org.alloytools.alloy.dist.jar")
    )
    if not alloy_jar.exists():
        raise FileNotFoundError(f"""Alloy JAR not found at {alloy_jar}. Please verify that:
            1. The path to the JAR file is correct: {alloy_jar}
            2. You have read permissions for this file""")
    try:
        with tempfile.NamedTemporaryFile(mode="w", suffix=".als", delete=True) as model:
            model.write(alloy_source)
            model.flush()

            cmd = [
                "java",
                "-jar",
                str(alloy_jar),
                "-D",
                "info",
                "exec",
                "--output",
                "-",
                "--type",
                "xml",
                model.name,
            ]

            alloy_xml = None
            alloy_err = None
            alloy_log = []

            try:
                result = subprocess.run(cmd, capture_output=True, text=True, check=True)

                alloy_xml = result.stdout
                alloy_log = [
                    logline
                    for line in result.stderr.splitlines()
                    if (logline := parse_info_json(line))
                ]

            except subprocess.CalledProcessError as cpe:
                alloy_err = "\n".join(
                    [
                        line
                        for line in cpe.stderr.splitlines()
                        if not is_info_line_match(line)
                    ]
                )

            return (alloy_xml, alloy_err, alloy_log)

    except PermissionError as pe:
        raise RuntimeError(f"""Failed to create temporary file for Alloy model. Error: {pe!r}
            This could be due to:
            1. Insufficient disk space
            2. Permission issues writing to temp directory
            3. System limitations on creating temporary files

            To fix: Check your system's temporary file permissions and available space.""")


from sys import argv

if __name__ == "__main__":
    """For testing the evaluator independent of the workflow/LLM framework"""

    logging.basicConfig(
        level=logging.INFO,
        format="%(levelname)s:%(name)s:%(message)s",
    )

    if len(argv) != 2:
        logger.info(f"Usage: {argv[0]} </path/to/als_file>")
    else:
        with open(argv[1], "r") as f:
            model = f.read()
            xml, err, logs = evaluate_alloy_model(model)
            logger.info(f"** xml:\n{xml}\n\n** err:\n{err}\n\n** loglines:\n{logs}")
