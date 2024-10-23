todo
====

These are several possibilities to document a todo:

- Explain what needs to be be done by using simple text.
- An *invisible* comment for the maintainers of the documentation.
- The third party ``sphinx.ext.todo`` directive:

  .. todo::

    It adds an intrusive todo-box for each todo. Use it with care to avoid noise in the
    documentation.
- The ``:todo:`` role from this extension for a short text like a single word.
  The todo-keyword is not visible, but you can still search for "todo" in the sources of the
  documentation.

  Example:

  .. list-table::
      :widths: 50 50
      :width: 100%
      :header-rows: 1

      * - html
        - rst
      * - :ref:`dox_util` and :todo:`another extension`.
        - .. code-block:: rst

            :ref:`dox_util` and :todo:`another extension`.
