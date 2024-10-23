Style Checks
============

This extension is capable of checking several style rules in configurable manner and hooks itself
up into the regular Sphinx build process. It's triggered by Sphinx as soon as all documents have
been discovered and filtered. Hence, only changed documents will be checked.

Built-In Checks
---------------

The following checks are included and enabled by default:

- - Whitespaces

    - ``trailing_whitespaces`` Trailing whitespaces are not allowed.

- - Heading Syntax

    - ``heading_levels`` Enforces the style of heading underline characters.
    - ``underline_length`` Headline underline length must match the length of the headline itself.

- - Top-Level Headings

    - ``top_level_heading`` All documents must have a top-level heading.
    - ``top_level_length`` Top-level heading must not exceed a configurable maximum length.
    - ``top_level_modulename`` The top-level heading in *index.rst* of modules must start with the
      module name.
    - ``top_level_casing`` Module name in top-level heading must match the module name
      in terms of capitalization.

- - Include Directives

    - ``include_rst`` Includes must not point to an ``*.rst`` file

Usage
-----

To use the dox_style extension just register it in ``conf.py``.

Configuration
-------------

To configure the checks, specify the ``stylecheck`` variable in ``conf.py``.
Only non-default values need to be specified.

The full list of options including defaults can be obtained by running

.. code-block:: shell

    python -m dox_style

from within the extension repository.

Global Options
++++++++++++++

+ Excluding files from all checks:

    .. code-block:: py

        'exclude': [<list of glob patterns>]  # default: []

+ Defining how many lines of context above/below the finding are show

    .. code-block:: py

        'excerpt': 4  # default: 2

Check-Specific Options
++++++++++++++++++++++

Each check has its own key in the ``stylecheck`` variable and features at least the following
options for globally disabling this check and to exclude certain files from this particular check:

.. code-block:: py

    'trailing_whitespaces': {'enabled': True, 'exclude': []}

All checks are enabled by default and their exclusion list is empty.

Examples
--------

This is an example configuration:

.. code-block:: py

    stylecheck = {
        'exclude': ['**/gptp/**'],
        'excerpt': 2,
        'trailing_whitespaces': {'exclude': ['**/3rdparty/**']},
        'top_level_length': {'limit': 40},
        'top_level_modulename': {'enabled': False}
    }

To disable all checks, use this configuration:

.. code-block:: py

    stylecheck = {
        'exclude': ['*'],
    }
