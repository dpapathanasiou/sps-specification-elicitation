from smolagents import tool

from algobot.tools.spytial_template import CLOSING, OPENING


@tool
def visualize_alloy_model(xml_data: str) -> str:
    """
    Use the results of the given Alloy model source code assessment
    from the Alloy evaluation tool, extract the xml stdout, and render
    a Spytial visualization, as a complete html page that can be shown
    in the Gradio app.

    Args:
        xml_data: the output of the Alloy model evaluation from the stdout portion of the Alloy evaluation tool. Should be valid xml, as a text string.
    """

    return f"""{OPENING}{xml_data}{CLOSING}"""
