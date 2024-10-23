.. _attributes_file:

Attributes File
===============

An attributes file is used to define project specific custom attributes which are not part
of standard Dim attributes.
Overwriting existing standard attributes is not allowed.

Syntax
------

.. code-block:: yaml

  attribute:
    type: <text|single|multi|split|list>
    default: <value>
    allowed: <list of allowed values>

Custom attributes have three parameters: `type`, `default` and `allowed`

type
++++

`type` defines the way the attributes are formatted and exported to RST. Allowed type values are

- text - The attribute information will be rendered as a text block in exported files.
- split - Comma separated values, split with newlines when rendered or exported.
- list - Comma separated values, split with spaces when rendered or exported.
- single - Attribute can have a single value from the list of allowed values.
- multi - Attribute can have multiple values from the list of allowed values, rendered like
  ``list``.

If `type` is set to `single` or `multi`, it is mandatory to provide the `allowed` list.

default
+++++++

Specifies the default value for the attributes.
For `single` and `multi` format type, the default value must be included in the list of allowed
values. All custom attributes should have a default value.
If no default value is provided, Dim adds a blank string as a default value.

Custom attributes must not have `auto` as a default value, Dim will throw an error in that case.

allowed
+++++++

Specifies the list of values a custom attribute can take.
Custom attributes with type `single` and `multi` must provide the allowed list of values.

Example
-------

.. code-block:: yaml

    cluster:
      type: text
      default: ''
    color:
      type: single
      default: 'red'
      allowed:
        - 'red'
        - 'green'
        - 'yellow'
        - 'blue'
