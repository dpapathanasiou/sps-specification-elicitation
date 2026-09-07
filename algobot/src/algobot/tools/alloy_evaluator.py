import logging
import subprocess
import tempfile
from os import getenv
from pathlib import Path

from dotenv import load_dotenv

_ = load_dotenv()  # read the .env file, if present


logger = logging.getLogger(__name__)


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
                "exec",
                "--output",
                "-",
                "--type",
                "xml",
                model.name,
            ]

            alloy_xml = None
            alloy_err = None

            try:
                result = subprocess.run(cmd, capture_output=True, text=True, check=True)

                if len(result.stderr) > 0:
                    alloy_err = result.stderr
                else:
                    alloy_xml = result.stdout

            except subprocess.CalledProcessError as cpe:
                alloy_err = cpe.stderr

            return (alloy_xml, alloy_err)

    except PermissionError as pe:
        raise RuntimeError(f"""Failed to create temporary file for Alloy model. Error: {pe!r}
            This could be due to:
            1. Insufficient disk space
            2. Permission issues writing to temp directory
            3. System limitations on creating temporary files

            To fix: Check your system's temporary file permissions and available space.""")
