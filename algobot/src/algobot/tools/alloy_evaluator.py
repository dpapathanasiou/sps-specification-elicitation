import logging
import subprocess
import tempfile
from os import getenv
from pathlib import Path

from dotenv import load_dotenv

_ = load_dotenv()  # read the .env file, if present


logger = logging.getLogger(__name__)


def evaluate_alloy_model(cargo):
    logger.info(f"evaluate_alloy_model -> {cargo}")

    alloy_jar = Path(
        getenv("SPS_ALLOY_JAR", "/usr/local/alloy/org.alloytools.alloy.dist.jar")
    )
    if not alloy_jar.exists():
        raise FileNotFoundError(f"""Alloy JAR not found at {alloy_jar}. Please verify that:
            1. The path to the JAR file is correct: {alloy_jar}
            2. You have read permissions for this file""")
    try:
        source = cargo["alloy"]
        with tempfile.NamedTemporaryFile(mode="w", suffix=".als", delete=True) as model:
            model.write(source)
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

            eval_error = False
            try:
                result = subprocess.run(cmd, capture_output=True, text=True, check=True)

                if len(result.stderr) > 0:
                    cargo["prior_error"] = result.stderr
                    eval_error = True

                cargo["alloy_xml"] = result.stdout

            except subprocess.CalledProcessError as cpe:
                cargo["prior_error"] = cpe.stderr
                eval_error = True

            if eval_error:
                return ("agent", cargo)

            return ("visualize_alloy", cargo)

    except PermissionError as pe:
        raise RuntimeError(f"""Failed to create temporary file for Alloy model. Error: {pe!r}
            This could be due to:
            1. Insufficient disk space
            2. Permission issues writing to temp directory
            3. System limitations on creating temporary files

            To fix: Check your system's temporary file permissions and available space.""")
