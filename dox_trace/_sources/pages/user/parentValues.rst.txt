Upstream and Derived Values
===========================

As additional information, values from direct and indirect upstream references are accumulated
and shown to ease consistency reviews.

The attribute *names* are displayed in grey color and bold font.
The attribute *values* are usually also displayed in grey color, but the font style can vary
depending on the content.

.. rubric:: Self-Written Specification Types

.. list-table::
    :width: 100%
    :widths: 20 16 16 16 16 16
    :header-rows: 1

    * -
      - srs
      - spec
      - mod
      - interface
      - unit
    * - :ref:`spec_upstream_asil`
      - x
      - x
      - x
      - x
      - x
    * - :ref:`spec_upstream_cal`
      - x
      - x
      - x
      - x
      - x
    * - :ref:`spec_upstream_tags`
      - x
      - x
      - x
      - x
      - x
    * - :ref:`spec_derived_feature`
      - x
      - x
      -
      - x
      - x
    * - :ref:`spec_derived_cr`
      - x
      - x
      -
      - x
      - x

.. rubric:: Generated Specification Types

.. list-table::
    :width: 100%
    :widths: 20 20 20 20 20
    :header-rows: 1

    * -
      - requirement |br| (input)
      - information |br| (input)
      - requirement |br| (software, system)
      - information |br| (software, system)
    * - :ref:`spec_upstream_asil`
      -
      -
      - x
      - x
    * - :ref:`spec_upstream_cal`
      -
      -
      - x
      - x
    * - :ref:`spec_upstream_tags`
      -
      -
      - x
      - x
    * - :ref:`spec_derived_feature`
      -
      -
      - x
      -
    * - :ref:`spec_derived_cr`
      -
      -
      - x
      -

.. _spec_upstream_asil:

Upstream Asil
-------------

| A comma separated list of all :ref:`spec_attr_asil` values of **direct** upstream references.
| Duplicated entries will be removed.
| Upstream references to *information* and struck through specifications are ignored.
| Will not be shown for input requirements.
| Example: ``ASIL_A, ASIL_B, not_set``.

.. _spec_upstream_cal:

Upstream Cal
------------

| A comma separated list of all :ref:`spec_attr_cal` values of **direct** upstream references.
| Duplicated entries will be removed.
| Upstream references to *information* and struck through specifications are ignored.
| Will not be shown for input requirements.
| Example: ``CAL_2, not_set``.

.. _spec_upstream_tags:

Upstream Tags
-------------

| A comma separated  list of all :ref:`spec_attr_tags` values of **direct** upstream references.
| Duplicated entries will be removed.
| Upstream references to *information* and struck through specifications are ignored.
| Will not be shown for input requirements.
| Example: ``srs, swa, smd, memory, obd, covered``.

.. _spec_derived_feature:

Derived Feature
---------------

| A comma separated  list of all :ref:`spec_attr_feature` values of **direct** and **indirect**
  upstream references.
| Duplicated entries will be removed.
| Upstream references to *information* and struck through specifications are ignored.
| Will not be shown for input requirements.
| Example: ``Feature 1, Feature 2``.

.. _spec_derived_cr:

Derived Change Request
----------------------

| A comma separated  list of all :ref:`spec_attr_change_request` values of **direct** and
  **indirect** upstream references.
| Duplicated entries will be removed.
| Upstream references to *information* and struck through specifications are ignored.
| Will not be shown for input requirements.
| Example: ``CR 1, CR 2``.
