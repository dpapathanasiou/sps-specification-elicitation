import logging
from datetime import UTC
from datetime import datetime as dt
from os import getenv
from pathlib import Path
from uuid import uuid4

from dotenv import load_dotenv

from algobot.tools.graph_database import GraphDatabase

_ = load_dotenv()  # read the .env file, if present


logger = logging.getLogger(__name__)

db_file = Path(getenv("SPS_DB_FILE", "/tmp/sps_db.sqlite3"))
db = GraphDatabase(db_file)


def log_model_version(cargo):
    id = uuid4().__str__()
    data = {
        "src": cargo["alloy"],
        "session": str(cargo["session"]),
        "user_input": cargo["user_input"],
        "ts": dt.now(tz=UTC).timestamp(),
    }

    db.insert(id, data)

    return ("user_input", cargo)
