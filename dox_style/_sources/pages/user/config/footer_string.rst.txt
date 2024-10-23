.. _sphinx_footer_string:

Footer String
=============

The page footer can be extended by an additional string.


- Specify the ``dox_style_footer`` variable in ``conf.py`` which must refer to a YAML file.

  Example:

    .. code-block:: python

        dox_style_footer = 'source/general/docu/sphinx/extensions/dox_style/footer.yaml'

- The YAML file must consist of key/value pairs. The keys must be relative paths from the root of
  the documentation to folders or files (without the ending). The values are the strings which shall
  be displayed.

  Example:

  .. code-block:: yaml

    modules/abc: Some text
    modules/xyz: Can also include <b>HTML</b> tags
    modules: All other modules...
    general/docu/sphinx/extensions/dox_style/footer_string: Additional <b>footer string</b> for this guideline<br>with a newline.
    ".": Default text

- When building the documentation, the page names are compared with the keys, the best match wins.
  The fallback for all pages is ``"."`` if available. In case no key matches, the additional footer
  is not displayed (not all pages may need an additional footer string).

Example (based on the YAML file above):

.. code-block:: none

    modules/abc/doc/index.rst          matches    modules/abc
    modules/foo/doc/bar.rst            matches    modules
    tools/python/fasel/doc/user.rst    matches    "."

.. note::

    If the file specified with ``dox_style_footer`` does not exist, no error is raised.
    This file may be generated (e.g. by calling "git log") which could take some time.
    In this case it's recommended to generate this file only in official builds and make the
    generation optional for local builds.
