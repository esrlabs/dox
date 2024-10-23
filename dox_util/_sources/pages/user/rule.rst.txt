rule
====

The *rule* role highlights a rule and provides a unique ID, which can be referenced within the
documentation.

Example:

.. list-table::
    :widths: 50 50
    :width: 100%
    :header-rows: 1

    * - html
      - rst
    * - :rule:`CodingConvention-Naming-Class`
        Class names must be written in ``CamelCase``.
      - .. code-block:: rst

            :rule:`CodingConvention-Naming-Class`
            Class names must be written in ``CamelCase``.
    * - This rule can be referenced like this:
        :ref:`CodingConvention-Naming-Class`.
      - .. code-block:: rst

            This rule can be referenced like this:
            :ref:`CodingConvention-Naming-Class`.

When exporting to HTML, anchors are created which can be used to reference these rules from a code
review tool. A rule refers to itself, which makes it easy to copy/paste the link.

Naming convention for the IDs: ``<Group>-<Number or Type>[-<Meaningful String>]``
