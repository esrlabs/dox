Newlines in Attributes
======================

For **attributes** there is a **limitation** in Sphinx, you cannot add empty lines, e.g. to
start a bullet list. In order to compensate that, newlines are *preserved*.

For example the following code does not work:

.. code-block:: rst

    .. <type>:: <id>
        :<attribute>:
            My list

            - ...
            - ...

            This is block text which
            is rendered in one line.

Instead, write it like this:

.. code-block:: rst

    .. <type>:: <id>
        :<attribute>:
            My list
            - ...
            - ...
            This is block text which is rendered in one line.

In order **not to preserve a newline**, end the line with a backslash:

.. code-block:: rst

    .. <type>:: <id>
        :<attribute>:
            A long text \
            without preserved \
            newlines.

This does not apply to the **content** of the specification.
