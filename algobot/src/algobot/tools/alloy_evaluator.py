import json
import subprocess
import tempfile
from os import getenv
from pathlib import Path

from dotenv import load_dotenv
from smolagents import tool

load_dotenv()  # read the .env file, if present


@tool
def evaluate_alloy_model(source: str) -> str:
    """
    Runs 'alloy exec' on the given source code string, and returns the evaluation report as a json string.

    Args:
        source: the source code of the Alloy model to evaluation. Should be valid Alloy syntax, as a text string, containing at least one statement to 'check' or 'run'.
    """

    alloy_jar = Path(
        getenv("SPS_ALLOY_JAR", "/usr/local/alloy/org.alloytools.alloy.dist.jar")
    )
    if not alloy_jar.exists():
        raise FileNotFoundError(
            f"Alloy JAR not found at {alloy_jar}. Please verify that:\n"
            f"1. The path to the JAR file is correct: {alloy_jar}\n"
            f"2. You have read permissions for this file"
        )
    try:
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
            try:
                result = subprocess.run(cmd, capture_output=True, text=True, check=True)

                output_result = {
                    "stdout": result.stdout,
                    "stderr": result.stderr,
                    "error": False,
                }

            except subprocess.CalledProcessError as cpe:
                # Provide detailed error information
                error_msg = (
                    f"Alloy execution failed with exit code {cpe.returncode}.\n"
                    f"Command executed: {' '.join(cmd)}\n\n"
                    f"Standard output:\n{cpe.stdout}\n\n"
                    f"Error output:\n{cpe.stderr}\n\n"
                    f"This error could be due to:\n"
                    f"1. Syntax errors in your Alloy model file\n"
                    f"2. Invalid command specified (command parameter)\n"
                    f"3. Solver configuration issues\n"
                    f"4. Memory constraints for large models\n"
                    f"5. File permissions problems\n\n"
                    f"To fix:\n"
                    f"1. Check that your .als file is syntactically correct (check the 'stderr' value)\n"
                    f"2. Verify command parameter is valid (e.g., 'check')\n"
                    f"3. Try different solver options if applicable\n"
                    f"4. Reduce depth or repeat parameters for large models"
                )

                output_result = {
                    "stdout": cpe.stdout,
                    "stderr": cpe.stderr,
                    "error": error_msg,
                }

            # Return JSON string as required by the tool specification
            return json.dumps(output_result)

    except PermissionError as pe:
        raise RuntimeError(
            f"Failed to create temporary file for Alloy model. Error: {pe!r}\n"
            f"This could be due to:\n"
            f"1. Insufficient disk space\n"
            f"2. Permission issues writing to temp directory\n"
            f"3. System limitations on creating temporary files\n\n"
            f"To fix: Check your system's temporary file permissions and available space."
        )


from sys import argv

if __name__ == "__main__":
    # for sanity-checking the tool independently of smolagents
    if len(argv) != 2:
        print(f"Usage: {argv[0]} </path/to/als_file>")
    else:
        with open(argv[1], "r") as f:
            model = f.read()
            result = evaluate_alloy_model(model)
            print(result)
