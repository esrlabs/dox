Calculated Values
=================

In addition to the *explicit* attributes, the following attributes are *calculated* and also shown
in the HTML output.

The attribute *names* are displayed in grey color and bold font.
The attribute *values* are usually also displayed in grey color, but the font style can vary
depending on the content.

.. rubric:: Self-Written Specification Types

.. list-table::
    :width: 100%
    :widths: 25 16 16 16 16 16
    :header-rows: 1

    * -
      - srs
      - spec
      - mod
      - interface
      - unit
    * - :ref:`spec_additional_upstream_references`
      - x
      - x
      - x
      - x
      - x
    * - :ref:`spec_additional_downstream_references`
      - x
      - x
      -
      - x
      - x

.. rubric:: Generated Specification Types

.. list-table::
    :width: 100%
    :widths: 25 20 20 20 20
    :header-rows: 1

    * -
      - requirement |br| (input)
      - information |br| (input)
      - requirement |br| (software, system)
      - information |br| (software, system)
    * - :ref:`spec_additional_upstream_references`
      - x
      - x
      - x
      - x
    * - :ref:`spec_additional_downstream_references`
      - x
      - x
      - x
      - x

.. _spec_additional_upstream_references:

Upstream References
-------------------

Collection of (backward) :ref:`refs <spec_attr_refs>` **to a higher** category and backward
:ref:`refs <spec_attr_refs>` **to the same** category as the specification.
They are shown as clickable links.

If no upstream reference is available,

- ``-`` is shown if

    - specification is struck through OR
    - tag *tool* is set OR
    - category is *input* is set OR
    - type is *information*,

- otherwise ``[missing]``.

An :ref:`example <spec_trace_up_down>` can be found on the :ref:`spec_trace` page.

.. _spec_additional_downstream_references:

Downstream References
---------------------

Collection of (backward) :ref:`refs <spec_attr_refs>` **to a lower** category and explicit
:ref:`refs <spec_attr_refs>` **to the same** category as the specification.
They are shown as clickable links or in red if a target does not exist.

If no downstream reference is available,

- ``-`` is shown if

    - specification is struck through OR
    - tag *covered* is set OR
    - type is *information* or *unit* OR
    - type is *interface and category is *module*,

- ``[missing]`` otherwise.

An :ref:`example <spec_trace_up_down>` can be found on the :ref:`spec_trace` page.
