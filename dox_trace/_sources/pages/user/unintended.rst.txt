.. _unintended_comments:

Unintended Comments
===================

It is pretty easy to accidentally write a comment instead of a specification, e.g.:

.. code-block:: rst

    .. spec:

        --> Should be ".. spec::"

    .. :mod

        --> Should be ".. mod::"

    .. interface

        --> Should be ".. interface::"

    .. :unit:

        --> Should be ".. unit::"

    .. srs..

        --> Should be ".. srs::"

This extensions forbids the strings ``srs``, ``spec``, ``mod``, ``interface`` and ``unit`` in the *first*
line of a comment if there are **no other non-word characters** in this line.

Allowed comments:

.. code-block:: rst

    ..
        A nice module.
        --> Other non-word characters in first line.

    ..  A nice interface.
        --> Other non-word characters in first line.

    ..
        First line.
        spec
        --> Forbidden string not in first line.
