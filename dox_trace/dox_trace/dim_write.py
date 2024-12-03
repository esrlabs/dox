import os.path
import re
import glob
import yaml

from .directives import DoxTraceDirective


def calc_folder(app, prefix):
    return os.path.join(app.config.dox_trace_dim_root, prefix).replace(os.sep, "/")


def calc_filename(app, prefix, docname):
    return os.path.join(calc_folder(app, prefix), docname + ".dim")


def dim_write(app):
    std = app.env.domaindata["std"]

    removed_folders = []
    for docname in std["local"]:
        ref_ids = app.env.domaindata["std"]["local_ordered"][docname]

        contents = {}  # category to content
        modules = {}  # category to module name
        for ref_id in ref_ids:
            spec_id = std["spec_id"][ref_id]
            options = std["spec_options"][ref_id]

            if "ignore_in_export" in options:
                continue

            role = options["role"]
            if role not in ["unit", "interface", "spec", "mod", "srs"]:
                continue

            # ensured that there is always a match in the beginning of run() in directives.py
            m = re.match(r"^(([^_]+)_[^_]+)", spec_id)
            module_name = m.group(1)
            category = m.group(2).lower()
            if category not in contents:
                modules[category] = module_name
                contents[category] = {}
            contents[category][spec_id] = options
            cmap = contents[category][spec_id]

            for key in list(cmap.keys()):
                if key not in DoxTraceDirective.attribute_mappings["valid_in_dim"]:
                    del cmap[key]

            if role in ["interface", "unit"]:
                cmap["tags"].append(role)

            for attr, value in cmap.items():
                if isinstance(value, list):
                    cmap[attr] = ", ".join(value)

        for category, module_name in modules.items():
            # delete old dim files
            if category not in removed_folders:
                removed_folders.append(category)
                folder = calc_folder(app, category)
                files = glob.glob(folder + "/**/*.dim", recursive=True)
                for file in files:
                    os.remove(file)

            dim_filename = calc_filename(app, category, docname)
            os.makedirs(os.path.dirname(dim_filename), exist_ok=True)
            with open(dim_filename, "w") as yaml_file:
                yaml_file.write("document: %s\n\n" % module_name)
                for k, v in contents[category].items():
                    entry = {k: v}
                    yaml_content = yaml.dump(entry)
                    yaml_file.write("\n")
                    yaml_file.write(yaml_content)
