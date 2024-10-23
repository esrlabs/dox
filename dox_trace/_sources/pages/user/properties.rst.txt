.. _properties:

Properties
==========

Properties, also called characteristics, are defined at a **single** location but can be used in
**several** places.

YAML Format
-----------

The properties are defined in an external ``YAML`` file like this:

.. code:: yaml

    SMD_cpp2can:
        asil: QM
        reuse: yes
    SMD_safeNvM:
        asil: ASIL_B
        reuse: no
        cal: CAL_2

You can write the information also in one line, it's just syntactic sugar:

.. code:: yaml

    SMD_cpp2can: { asil: QM,     reuse: yes            }
    SMD_safeNvM: { asil: ASIL_B, reuse: no, cal: CAL_2 }

Multi-line strings are also supported:

.. code:: yaml

    SWA_mod_abcAdapter:
        content: |
                 This module is about

                  - this
                  - that

| A referenced but missing property will lead to an error!
| It is possible to define default values with the special ID ``_default_``.

Sphinx Configuration
--------------------

Configure the filename of the properties in ``conf.py``:

.. code::

    properties_file = '<some path>/properties.yaml'

Specification Usage
-------------------

It is possible to overwrite the default values for attributes of specifications.

The property ID is matched in the following order:

- Equal to the complete specification ID, e.g. *SMD_cpp2can_abc*
- Equal to the specification ID until one character before the second "_", e.g. *SMD_cpp2can*
- Equal to the specification ID until one character before the first "_", e.g. *SMD*
- Equal to *_default_*

If

- a specification in an RST file does not specify an attribute explicitly and
- the ID is found in the properties file and
- the attribute is defined for this ID in the properties file

then the corresponding value is used instead of the standard default value defined in
:ref:`dim_attr` and :ref:`dim_custom_attr`. This applies to all explicit attributes as well as for
the content of the specifications.

Example:

**properties.yaml:**

.. code:: yaml

    SMD_cpp2can: { asil: QM, cal: CAL_1 }
    SWA:         { developer: MyCompany }

**RST:**

.. code:: rst

    .. spec:: SMD_cpp2can_abc
        :cal: CAL_4

    .. spec:: SWA_featureX_abc

**HTML:**

.. spec:: SMD_cpp2can_abc
    :cal: CAL_4

.. spec:: SWA_featureX_abc

Standalone Usage
----------------

Properties can be used as a *role* or as a *directive*:

- role: ``:prop:`<key>:<value>```
- directive: ``.. prop:: <key>:<value>``

These are the main differences:

.. list-table::
    :header-rows: 1

    * - Role
      - Directive
    * - Inline text
      - Separate block
    * - Single-line
      - Multi-line
    * - Value interpreted as string
      - Value interpreted as RST
    * - Styled with CSS
      - Rendered by Sphinx

Example:

**properties.yaml:**

.. code:: yaml

    _default_: { key3: value3 }

    ID1:
        key1: value1
        key2: value2

**RST:**

.. code:: rst

    The values: :prop:`ID1:key1`, :prop:`ID1:key2`, :prop:`ID1:key3`

    .. list-table::
        :header-rows: 1

        * - Key
          - Value
        * - key1
          - .. prop:: ID1:key1
        * - key2
          - .. prop:: ID1:key2
        * - key3
          - .. prop:: ID1:key3

**HTML:**

:prop:`ID1:key1`, :prop:`ID1:key2`, :prop:`ID1:key3`

.. list-table::
    :header-rows: 1

    * - Key
      - Value
    * - key1
      - .. prop:: ID1:key1
    * - key2
      - .. prop:: ID1:key2
    * - key3
      - .. prop:: ID1:key3
