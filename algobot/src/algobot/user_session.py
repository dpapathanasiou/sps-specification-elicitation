from json import dumps
from uuid import uuid4


class UserSession:
    def __init__(self):
        self.id = uuid4().__str__()
        self.version = 0

    def increment(self):
        self.version += 1

    def __str__(self):
        return dumps({"id": self.id, "version": self.version})
