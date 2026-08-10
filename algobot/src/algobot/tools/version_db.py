import json
from os import getenv
from pathlib import Path
from uuid import uuid4

from dotenv import load_dotenv
from smolagents import tool

from algobot.tools.graph_database import GraphDatabase

load_dotenv()  # read the .env file, if present

db_file = Path(getenv("SPS_DB_FILE", "/tmp/sps_db.sqlite3"))
db = GraphDatabase(db_file)


@tool
def log_model_version(source: str) -> str:
    """
    Saves the given model to the version database: this tool accepts a string, corresponding to the Alloy model to save, and logs it in the version database.

    Args:
        source: The source code of the Alloy model to save.
    """

    # TODO track corresponding user and prior version id for this session
    id = uuid4().__str__()
    data = {"src": source}
    db.insert(id, data)

    result = {"id": id}
    return json.dumps(result)
