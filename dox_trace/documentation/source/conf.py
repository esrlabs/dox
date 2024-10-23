import sys
from pathlib import Path
from datetime import datetime

EXTENSION_ROOT = Path("../../..")
sys.path.extend([str(path.resolve()) for path in EXTENSION_ROOT.glob("*")])

project = "dox_trace"
author = "Accenture"
copyright = f"{datetime.now().year} Accenture"

global __version__
exec(open(f"../../{project}/version.py", "r").read(), globals())
version = __version__

html_context = {"document_status_default": "Released", "data_classification_default": None}

extensions = [
    "sphinxcontrib.jquery",
    "dox_style",
    "dox_trace",
]

exclude_patterns = ["pages/requirements-generated/index*"]

numfig = True

dox_trace_allow_deprecated = True
dox_trace_allow_undefined_refs = True

dox_trace_properties_file = "properties.yaml"

dox_style_footer = "footer.yaml"

# Note: the following option will be included to customAttributes.rst!
# START dox_trace_custom_attributes
dox_trace_custom_attributes = {
    "custom_text": {
        "directives": ["spec", "unit"],
        "type": "text",
        "default": "THIS IS THE DEFAULT VALUE",
    },
    "custom_enum": {
        "directives": ["spec", "unit"],
        "type": "enum",
        "default": ["x", "y"],
        "export": "yes",
    },
    "custom_refs": {
        "directives": ["spec", "requirement"],
        "categories": ["input"],
        "type": "refs",
    },
}
# END dox_trace_custom_attributes
