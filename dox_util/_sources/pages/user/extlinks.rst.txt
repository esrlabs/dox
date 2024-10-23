extlinks
========

The ``sphinx.ext.extlinks`` third party extension provides base paths for external links.
These base paths are set up once in conf.py and can be used from the rst files.

With ``dox_util`` it is possible to specify relative paths based on the root of the
documentation (in the *Makefile* usually called *SOURCE*).

Example:

.. list-table::
    :widths: 50 50
    :header-rows: 1

    * - html
      - conf.py / rst
    * - Accenture :website:`careers <careers>`.

        See also :other_doc:`some/folder`.

        See also :other_doc:`other doc <some/folder>`.
      - .. code-block:: rst

            # conf.py

            extensions = [
                ...
                'sphinx.ext.extlinks',
                'dox_util'
            ]

            extlinks = {'website'    ('https://accenture.com/%s', None),
                        'other_doc': ('../../other/%s', None)}

            # RST file

            Accenture :website:`careers <careers>`.

            See also :other_doc:`some/folder`.

            See also :other_doc:`other doc <some/folder>`.

It's a good practice to use the *replace* directive provided by Sphinx.

Example:

.. list-table::
    :widths: 50 50
    :header-rows: 1

    * - html
      - rst
    * - Accenture |careers|.

        .. |careers| replace:: :website:`careers <careers>`
      - .. code-block:: rst

            # very readable text
            Accenture |careers|.

            # usually defined at the bottom of the document
            .. |careers| replace:: :website:`careers <careers>`
