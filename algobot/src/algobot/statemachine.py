"""
StateMachine class

Based on David Mertz's article "Charming Python: Generator-based
State Machines and Coroutines"
(https://gnosis.cx/publish/programming/charming_python_b5.html).

Updated to include two variables useful in exception reporting: the
current state and the current cargo.
"""


class StateMachine:
    def __init__(self):
        self.handlers = {}
        self.start_state = None
        self.ending_states = []
        self.current_state = None
        self.current_cargo = None

    def add_state(self, name, handler, is_end_state=None):
        if not is_end_state:
            is_end_state = False
        self.handlers[name] = handler
        if is_end_state:
            self.ending_states.append(name)

    def set_start(self, name):
        self.start_state = name

    def run(self, cargo):
        try:
            handler = self.handlers[self.start_state]
        except RuntimeError:
            raise RuntimeError(
                "StateMachine Initialization Error: you must call .set_start() before .run()"
            )
        if not self.ending_states:
            raise RuntimeError(
                "StateMachine Initialization Error: at least one state must be an end_state"
            )

        while 1:
            (next_state, cargo) = handler(cargo)
            self.current_state = next_state
            self.current_cargo = cargo
            if next_state in self.ending_states:
                break
            else:
                handler = self.handlers[next_state]
