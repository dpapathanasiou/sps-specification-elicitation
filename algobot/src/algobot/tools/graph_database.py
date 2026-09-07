import json
import sqlite3

SCHEMA = """
CREATE TABLE IF NOT EXISTS nodes (
    body TEXT,
    id   TEXT GENERATED ALWAYS AS (json_extract(body, '$.id')) VIRTUAL NOT NULL UNIQUE
);

CREATE INDEX IF NOT EXISTS id_idx ON nodes(id);

CREATE TABLE IF NOT EXISTS edges (
    source     TEXT,
    target     TEXT,
    properties TEXT,
    UNIQUE(source, target, properties) ON CONFLICT REPLACE,
    FOREIGN KEY(source) REFERENCES nodes(id),
    FOREIGN KEY(target) REFERENCES nodes(id)
);

CREATE INDEX IF NOT EXISTS source_idx ON edges(source);
CREATE INDEX IF NOT EXISTS target_idx ON edges(target);
"""

INSERT_NODE = """INSERT INTO nodes VALUES(json(?))"""

INSERT_EDGE = """INSERT INTO edges VALUES(?, ?, json(?))"""

SELECT_NODE = """SELECT body FROM nodes WHERE id = ?"""

SELECT_NODES_LIKE = """SELECT body FROM nodes WHERE id LIKE ? || '%' ORDER BY id ASC"""


def atomic(db_file, cursor_exec_fn):
    """Execute the function as an atomic transaction in the given database (sqlite file)"""
    connection = None
    try:
        connection = sqlite3.connect(db_file)
        cursor = connection.cursor()
        cursor.execute("PRAGMA foreign_keys = TRUE;")
        results = cursor_exec_fn(cursor)
        connection.commit()
    finally:
        if connection:
            connection.close()
    return results


def initialize(db_file):
    def _init(cursor):
        cursor.executescript(SCHEMA)

    return atomic(db_file, _init)


def _set_id(identifier, data):
    if identifier is not None:
        data["id"] = identifier
    return data


def _insert_node(cursor, identifier, data):
    cursor.execute(INSERT_NODE, (json.dumps(_set_id(identifier, data)),))


def add_node(data, identifier=None):
    def _add_node(cursor):
        _insert_node(cursor, identifier, data)

    return _add_node


def connect_nodes(source_id, target_id, properties=None):
    if properties is None:
        properties = {}

    def _connect_nodes(cursor):
        cursor.execute(
            INSERT_EDGE,
            (
                source_id,
                target_id,
                json.dumps(properties),
            ),
        )

    return _connect_nodes


def _parse_search_results(results, idx=0):
    return [json.loads(item[idx]) for item in results]


def find_nodes(id, use_like=False):
    def _find_nodes(cursor):
        query = SELECT_NODES_LIKE if use_like else SELECT_NODE
        return _parse_search_results(cursor.execute(query, (id,)).fetchall())

    return _find_nodes


class GraphDatabase:
    """
    A graph database in sqlite, inspired by [simple-graph](https://github.com/dpapathanasiou/simple-graph).

    Attribute
        db_file: absolute path to the sqlite file (will be created if it does not exist), as a string

    Method
        insert:
            id -> string, corresponding to data (must be unique)
            data -> json object
            predecessor_id -> if present, connects this data to the corresponding object
    """

    def __init__(self, db_file):
        self.db_file = db_file
        initialize(self.db_file)

    def insert(self, id, data, predecessor_id=None):
        atomic(self.db_file, add_node(data, id))
        if predecessor_id:
            atomic(self.db_file, connect_nodes(predecessor_id, id))

    def select(self, id, use_like=False):
        return atomic(self.db_file, find_nodes(id, use_like))

    def __str__(self):
        return f"GraphDatabase: {self.db_file}"
