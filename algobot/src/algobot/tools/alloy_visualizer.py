from gradio.components.html import HTML
from smolagents import tool

from algobot.tools.spytial_template import (
    CSS_TEMPLATE,
    HEAD,
    HTML_TEMPLATE,
    JS_CLOSING,
    JS_OPENING,
)


@tool
def visualize_alloy_model(xml_data: str) -> HTML:
    """
    Use the results of the given Alloy model source code assessment
    from the Alloy evaluation tool, extract the xml stdout, and render
    a Spytial visualization, as a complete html page that can be shown
    in the Gradio app.

    Args:
        xml_data: the output of the Alloy model evaluation from the stdout portion of the Alloy evaluation tool. Should be valid xml, as a text string.
    """

    js_content = f"""{JS_OPENING}{xml_data}{JS_CLOSING}"""
    spytial = HTML(
        head=HEAD,
        js_on_load=js_content,
        css_template=CSS_TEMPLATE,
        html_template=HTML_TEMPLATE,
    )
    return spytial
