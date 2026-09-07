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


def visualize_alloy_model(alloy_xml):
    logger.info(f"visualize_alloy_model -> {alloy_xml}")

    js_content = f"""{JS_OPENING}{alloy_xml}{JS_CLOSING}"""
    spytial = HTML(
        head=HEAD,
        js_on_load=js_content,
        css_template=CSS_TEMPLATE,
        html_template=HTML_TEMPLATE,
    )

    return spytial
