import sys
from pathlib import Path
from datetime import datetime

EXTENSION_ROOT = Path("../..")
sys.path = [str(path.resolve()) for path in EXTENSION_ROOT.glob("dox_*")] + sys.path

project = "Dox"
author = "Accenture"
copyright = f"{datetime.now().year} Accenture"

version = "1.0.0"

html_context = {"document_status_default": "Released", "data_classification_default": None}

extensions = ["sphinxcontrib.jquery", "sphinx.ext.extlinks", "sphinx.ext.todo", "dox_style"]

dox_style_footer = "footer.yaml"
