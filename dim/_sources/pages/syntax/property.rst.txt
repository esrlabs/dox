.. _property_files:

Properties File
===============

A properties file is a YAML file that consists of key-value pairs. Dim uses the properties file for
**replacing attributes in requirements which are not explicitly set**.
The properties are specified on document level.

Any unknown attributes in the properties file are ignored.

Syntax
------

.. code-block:: yaml

    <document name>:
      <attribute 1>: value 1
      <attribute 2>: value 2
      <attribute n>: value n

    # can be also written like this:

    <document name>: { <attribute 1>: value 1,  <attribute 2>: value 2, <attribute n>: value n }

Example
-------

.. code-block:: yaml

    # properties.yaml
    SRS_featureX:
      asil: ASIL_A
      text: |
            Multi-line
            example text.
      other_key: other value

    SRS_featureY:
      verification_methods: on_target
      asil: ASIL_C

.. code-block:: yaml

   # config.dim
   Config:
     - originator: MyCompany
       files:
         - featureX.dim
         - featureY.dim
       category: software

   Properties: properties.yaml

.. code-block:: yaml

   # featureX.dim
   document: SRS_featureX

   SRS_featureX_0001:
     text: text example

   SRS_featureX_0002:
      asil: not_set

.. code-block:: yaml

   # featureY.dim
   document: SRS_featureY

   SRS_featureY_0001:
     asil: ASIL_A

   SRS_featureY_0002:

The following changes will be applied:

- ``asil`` value for requirement ID **SRS_featureX_0001** will be replaced with
  ``ASIL_A``, because requirements file is missing a value for asil attribute.
- ``asil`` value for requirement ID **SRS_featureX_0002** will not be replaced with
  ``ASIL_A``, because value **not_set** is explicitly set for asil attribute
- ``verification_methods`` attribute will be replaced with ``on_target`` for requirement
  ID **SRS_featureY_0001** as ``verification_methods`` is missing.
- Requirement with ID **SRS_featureY_0002** will have ``asil`` value ``ASIL_C``,
  as value for attribute ``asil`` was empty, and ``verification_methods`` will be replaced
  with ``on_target``.
- ``other_key`` will be ignored without raising an error.

Internally in Dim, the requirements are treated as if they were written that way:

.. code-block:: yaml

   # featureX.dim
   document: SRS_featureX

   SRS_featureX_0001:
     text: text example
     asil: ASIL_A

   SRS_featureX_0002:
     asil: not_set

.. code-block:: yaml

   # featureY.dim
   document: SRS_featureY

   SRS_featureY_0001:
     asil: ASIL_A
     verification_methods: on_target

   SRS_featureY_0002:
     asil: ASIL_C
     verification_methods: on_target
