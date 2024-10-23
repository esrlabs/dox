Enclosed Files
==============

Sphinx does not recognize files which are referenced in a non-Sphinx syntax, e.g. in raw-html:

.. code-block:: rst

    .. spec::

        Some text: :raw-html:`<img src="folder/image1.png" />`

    .. spec::

        Implement the following:
        :raw-html:`<a href="table.xlsx">download table</a>`

To make these files available in the output folder, add an ``enclosed`` directive to the RST-file:

.. code-block:: rst

    .. enclosed::

        folder/image1.png
        table.xlsx

Add one file per line without comma or bullet points.

.. note::

    This directive is a workaround if you need to generate RST files from HTML sources.
    If possible, use regular Sphinx syntax instead to avoid this workaround.
