import logging
from datetime import UTC
from datetime import datetime as dt
from os import getenv
from pathlib import Path

from dotenv import load_dotenv

from algobot.tools.graph_database import GraphDatabase

_ = load_dotenv()  # read the .env file, if present


logger = logging.getLogger(__name__)

db_file = Path(getenv("SPS_DB_FILE", "/tmp/sps_db.sqlite3"))
db = GraphDatabase(db_file)


def log_model_version(session, alloy_code, user_input):
    id = session.get_as_id()

    data = {
        "src": alloy_code,
        "user_input": user_input,
        "ts": dt.now(tz=UTC).timestamp(),
    }

    db.insert(id, data)


def get_all_model_versions(session):
    return db.select(session.get_id(), use_like=True)


def get_current_model_version(session):
    return db.select(session.get_as_id(), use_like=False)
