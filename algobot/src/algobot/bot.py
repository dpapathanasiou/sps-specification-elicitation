import argparse
import logging

from algobot.statemachine import StateMachine
from algobot.tools.alloy_bot import AlloyBot
from algobot.tools.alloy_evaluator import evaluate_alloy_model
from algobot.tools.alloy_visualizer import visualize_alloy_model
from algobot.tools.user_prompt import get_user_confirmation, get_user_input
from algobot.tools.version_db import log_model_version

if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(levelname)s:%(name)s:%(message)s",
    )

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--show_config",
        help="print the agent configuration, including models and prompts used",
        type=bool,
        default=True,
    )
    parser.add_argument(
        "--force_index_rebuild",
        help="rebuild the corpus index, regardless of whether or not it already exists",
        type=bool,
        default=False,
    )
    args = parser.parse_args()

    m = StateMachine()
    try:
        m.add_state("user_input", get_user_input)
        m.set_start("user_input")

        agent = AlloyBot()
        m.add_state("agent", agent.model_alloy)
        m.add_state("evaluate_alloy", evaluate_alloy_model)
        m.add_state("visualize_alloy", visualize_alloy_model)
        m.add_state("user_confirm", get_user_confirmation)
        m.add_state("log_version", log_model_version)

        m.add_state("done", None, is_end_state=True)

        m.run({})

    # in the event of an exception, capture the current
    # state and cargo dict and use the information
    # as part of the message sent to stdout
    except Exception as e:
        exception_data = {"state": m.current_state}
        if m.current_cargo:
            exception_data["cargo"] = m.current_cargo
        e.args = (exception_data,)
        raise
