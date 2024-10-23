source
======

``dox_util`` provides several ways to reference source code.

Including a Source File
-----------------------

The Sphinx built-in ``literalinclude`` has an unpleasant downside. The path in RST and therefore in
HTML is relative to the rst-file, so typically some ".." are included.

With ``sourceinclude`` from this extension it is possible to specify files relative from the folder
above *doc*.

Comparison example:

.. code-block::

    <module_root>/doc/sub/page.rst
    <module_root>/include/mod/example.h

.. code-block:: rst

    .. literalinclude:: ../../include/mod/example.h
        :start-after: MARKER1
        :end-before: MARKER2
        :language: c++
        :dedent: 4
        :caption:

    .. sourceinclude:: include/mod/example.h
        :start-after: MARKER1
        :end-before: MARKER2
        :language: c++
        :dedent: 4
        :caption:

In case no *doc* folder is in the path between Sphinx root and the rst-file, the source file can
also be specified relative to the rst-file.

Referencing a Source File
-------------------------

To simply reference a source file use ``:source:`<relative path to file>```.
The result will be a highlighted string, not a clickable reference.
The path is relative to the module root, similar to ``sourceinclude``.
This role checks for **existence** of the file. In case the file does not exist, an error is
returned.

| Example:
| ``:source:`source/include/MemoryManager.h``` results in :source:`source/include/MemoryManager.h`.


Note, that Sphinx has a built-in type ``:file:``. It does *no* existence check and it is relative to
the rst-file.

| Example:
| ``:file:`source/include/DoesNotExist.h``` results in :file:`source/include/DoesNotExist.h`.
