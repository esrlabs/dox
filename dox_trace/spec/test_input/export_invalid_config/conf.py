import sys
from pathlib import Path

EXTENSION_ROOT = Path("../../../../")
sys.path.extend([str(path.resolve()) for path in EXTENSION_ROOT.glob("*")])

extensions = ["dox_style", "dox_trace", "sphinxcontrib.jquery"]

dox_trace_dim_root = ":invalid\n\0invalid:"
