.. _dim_custom_attr:

Custom Attributes
=================

The :ref:`dim_attr` can be extended by custom attributes using the *dox_trace_custom_attributes*
option in ``conf.py``.

Syntax
------

.. code:: python

    dox_trace_custom_attributes = {
        <name>: {
            "directives": <directives-list>, # mandatory
            "categories": <categories-list>, # mandatory if directives include "requirement" or "information"
            "type": "text|enum|refs",        # mandatory
            "default": <default>,            # optional, defaults to "" or [], depending on type
            "export": "yes|no"               # optional, defaults to "no"
        }
        ...
    }

*dox_trace_custom_attributes* must be a hash with:

- key: name of the attribute
- value: parameter of the attribute

The names must be unique and not conflict with :ref:`dim_attr`.

Parameters
----------

**directives** is mandatory; it lists all specification :ref:`spec_types` for which the attribute
shall be available. It must be a non-empty list of strings.

**categories** is mandatory if the *directives* parameter includes *requirement* or *information*.
It must be a non-empty list of strings containing *input*, *system* and/or *software*.

**type** is mandatory; must be one of *text*, *enum* and *refs*.

- *text*: Attribute value interpreted as **RST syntax**.
- *enum*: Comma separated **textual** string list.
- *refs*: Comma separated list of **Sphinx references**. The references are not considered for
  calculating downstream or upstream references.

**default** is optional; used if the attribute is not set explicitly in specifications.

**export** is optional; setting to "yes" enables the export to Dim files. Note, that the Dim
configuration must also support this attribute.

Values
------

An attribute value is one of the following (in that particular order):

- explicitly set in the specifications
- defined in the :ref:`properties files <properties>`
- taken from the **default** parameter
- ``""`` or ``[]``, depending on the **type**

The output is formatted according to the type. Empty attributes are rendered as ``-``.

Example
-------

conf.py:

.. literalinclude:: ../../conf.py
    :start-after: START dox_trace_custom_attributes
    :end-before: END dox_trace_custom_attributes
    :language: python

RST file:

.. literalinclude:: customAttributesExample.inc
    :language: rst

Rendered output:

.. include:: customAttributesExample.inc
