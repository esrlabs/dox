.. _common_warnings:

Common Issues
=============

Parsing YAML
------------

| In some situations, the Ruby YAML parser does not print the correct line and column numbers.
| Example:

.. code-block:: yaml

    ID_ABC_xy:
      text: ...
      status: valid
     tags: memory
      asil: ASIL_B

A space before *tags* is missing, but the following error message is printed:

.. code-block:: none

    ... did not find expected key while parsing a block mapping at line 1 column 1

This error message usually means you have too much or too less spaces *somewhere* in
the YAML file.

This is a known issue, see https://github.com/ruby/psych/issues/190.
