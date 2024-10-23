import sys
from pathlib import Path
from datetime import datetime

EXTENSION_ROOT = Path("../../..")
sys.path = [str(path.resolve()) for path in EXTENSION_ROOT.glob("dox_*")] + sys.path

project = "Dim"
author = "Accenture"
copyright = f"{datetime.now().year} Accenture"

html_context = {"document_status_default": "Released", "data_classification_default": None}

extensions = [
    "sphinxcontrib.jquery",
    "dox_style",
    "dox_trace",
]

with open("../../version.txt", "r") as file:
    version = file.read().strip()

exclude_patterns = ["pages/requirements/index*"]

numfig = True

dox_style_footer = "footer.yaml"
