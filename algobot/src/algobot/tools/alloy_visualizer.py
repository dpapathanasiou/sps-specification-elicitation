import logging

from gradio.components.html import HTML

from algobot.tools.spytial_template import (
    CSS_TEMPLATE,
    HEAD,
    HTML_TEMPLATE,
    JS_CLOSING,
    JS_OPENING,
)

logger = logging.getLogger(__name__)


def visualize_alloy_model(cargo):
    logger.info(f"visualize_alloy_model -> {cargo}")

    xml_data = cargo["alloy_xml"]
    js_content = f"""{JS_OPENING}{xml_data}{JS_CLOSING}"""
    spytial = HTML(
        head=HEAD,
        js_on_load=js_content,
        css_template=CSS_TEMPLATE,
        html_template=HTML_TEMPLATE,
    )

    logger.info(spytial)
    return ("user_confirm", cargo)
