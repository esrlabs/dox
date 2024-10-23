toctree
=======

.. _tolerant-toctree:

tolerant-toctree
----------------

The ``tolerant-toctree`` directive works the same as the regular ``toctree``
directive except that non-existing files will not result in a warning.

| Glob pattern ``*`` and ``?`` are supported, e.g. *toctree/example\**.
| If no file is found, the toctree is not rendered.

It's used when files are generated and/or are not always there.

Example:

.. list-table::
    :widths: 50 50
    :header-rows: 1

    * - html
      - rst
    * - .. tolerant-toctree::
            :caption: Tree 1
            :glob:

            toctree/example1
            toctree/*2
            toctree/example3

        .. tolerant-toctree::
            :caption: Tree 2
            :glob:

            toctree/doesNot*Exist
            toctree/sameHere

      - .. code-block:: rst

            .. tolerant-toctree::
                :caption: Tree 1
                :glob:

                toctree/example1
                toctree/*2
                toctree/example3

            .. tolerant-toctree::
                :caption: Tree 2
                :glob:

                toctree/doesNot*Exist
                toctree/sameHere

| *toctree/example3* does not exist, so this entry will be ignored.
| *Tree 2* is completely hidden because no files are found.

doclist
-------

| The ``doctree`` directive creates a flat bullet list of doc-links.
  The same glob pattern as for ``toctree`` are supported.
| It has no options.


Example:

.. list-table::
    :widths: 50 50
    :header-rows: 1

    * - html
      - rst
    * - .. doclist::

            toctree/example1
            toctree/example2
            *

      - .. code-block:: rst

            .. doclist::

                toctree/example1
                toctree/example2
                *
