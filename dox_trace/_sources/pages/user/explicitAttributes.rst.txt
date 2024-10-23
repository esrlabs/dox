.. _dim_attr:

Standard Attributes
===================

The different :ref:`specification types <spec_types>` support different attributes.

None of the attributes is mandatory from tooling perspective, but they have default values which
can differ depending on the ID, type, etc.

In general the syntax is as follows:

.. code-block:: rst

    .. <type>:: <id>
        :<attribute 1>: <value 1>
        :<attribute 2>: <value 2>

        <content>

Similar to the content, the values can be **simple text** or any other **complex Sphinx syntax**
like images, lists, blocks and even headings.

Many attributes are the same as for **Dim**, especially regarding the allowed values.
Sphinx itself does not complain (yet) if e.g. an incorrect status value is set, but it's recognized
when :ref:`exported <spec2dim>` and loaded by Dim.

The attribute *names* are displayed in black color and bold font.
The attribute *values* are usually also displayed in black color, but the font style can vary
depending on the content.

Note: it is recommended to do that export and "dim check" in the verifier of a project to avoid
broken attributes.

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
    * - :ref:`spec_attr_status`
      - x
      - x
      - x
      - x
      - x
    * - :ref:`spec_attr_review_status`
      - \(x)
      - \(x)
      - \(x)
      - \(x)
      - \(x)
    * - :ref:`spec_attr_asil`
      - x
      - x
      - x
      - x
      - x
    * - :ref:`spec_attr_cal`
      - x
      - x
      - x
      - x
      - x
    * - :ref:`spec_attr_reuse`
      -
      -
      - x
      -
      -
    * - :ref:`spec_attr_usage`
      -
      -
      - x
      -
      -
    * - :ref:`spec_attr_tags`
      - x
      - x
      -
      - x
      - x
    * - :ref:`spec_attr_developer`
      - x
      - x
      - x
      - x
      - x
    * - :ref:`spec_attr_tester`
      - x
      - x
      -
      - \(x)
      - x
    * - :ref:`spec_attr_verification_methods`
      - x
      - x
      -
      - \(x)
      - x
    * - :ref:`spec_attr_verification_criteria`
      - x
      - x
      -
      - \(x)
      - x
    * - :ref:`spec_attr_comment`
      -
      -
      -
      -
      -
    * - :ref:`spec_attr_miscellaneous`
      -
      -
      -
      -
      -
    * - :ref:`spec_attr_feature`
      -
      -
      -
      -
      -
    * - :ref:`spec_attr_change_request`
      -
      -
      -
      -
      -
    * - :ref:`spec_attr_sources`
      - \(x)
      - \(x)
      -
      - \(x)
      - x
    * - :ref:`spec_attr_refs`
      - x
      - x
      -
      - x
      - x
    * - :ref:`spec_attr_location`
      -
      -
      - x
      -
      -
    * - :ref:`spec_attr_category`
      -
      -
      -
      -
      -

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
    * - :ref:`spec_attr_status`
      - x
      - x
      - x
      - x
    * - :ref:`spec_attr_review_status`
      - x
      - \(x)
      - \(x)
      - \(x)
    * - :ref:`spec_attr_asil`
      - x
      - x
      - x
      - x
    * - :ref:`spec_attr_cal`
      - x
      - x
      - x
      - x
    * - :ref:`spec_attr_reuse`
      -
      -
      -
      -
    * - :ref:`spec_attr_usage`
      -
      -
      -
      -
    * - :ref:`spec_attr_tags`
      - x
      - x
      - x
      - x
    * - :ref:`spec_attr_developer`
      - x
      -
      - x
      -
    * - :ref:`spec_attr_tester`
      - x
      -
      - x
      -
    * - :ref:`spec_attr_verification_methods`
      - x
      -
      - x
      -
    * - :ref:`spec_attr_verification_criteria`
      - x
      -
      - x
      -
    * - :ref:`spec_attr_comment`
      - x
      - x
      -
      -
    * - :ref:`spec_attr_miscellaneous`
      - x
      - x
      -
      -
    * - :ref:`spec_attr_feature`
      - x
      - x
      -
      -
    * - :ref:`spec_attr_change_request`
      - x
      - x
      -
      -
    * - :ref:`spec_attr_sources`
      - \(x)
      - \(x)
      - \(x)
      - \(x)
    * - :ref:`spec_attr_refs`
      - x
      - x
      - x
      - x
    * - :ref:`spec_attr_location`
      -
      -
      -
      -
    * - :ref:`spec_attr_category`
      - \(-)
      - \(-)
      - \(-)
      - \(-)


- Empty cell = attribute not available and never shown in HTML output
- ``x`` = shown in HTML output
- ``(x)`` = shown in HTML output under certain conditions, see below
- ``(-)`` = attribute available, but not shown in HTML output

.. _spec_attr_status:

status
------

Default value: ``draft``

If *status* is set to ``invalid``, the requirement will be struck through.

.. _spec_attr_review_status:

review_status
-------------

| Only shown for input requirements (not software requirements) or if the value is != ``accepted``.
| Default value: ``accepted``.

If *review_status* is set to ``rejected`` or ``not_relevant``, the requirement will be struck
through.

.. _spec_attr_asil:

asil
----

Default value: ``not_set``

.. _spec_attr_cal:

cal
---

Default value: ``not_set``

.. _spec_attr_reuse:

reuse
-----

| Describes if the module is (partly) reused or developed from scratch.
  Use a short string without new lines, e.g. "yes" and "no".
| Default value is empty string which is displayed as ``-``.

.. _spec_attr_usage:

usage
-----

| Describes in which environment the module is used.
  Use a short string without new lines, e.g. "production", "debug", "testing"
| Default value is empty string which is displayed as ``-``.

.. _spec_attr_tags:

tags
----

| A string with comma separated values.
| Default value is empty string which is displayed as ``-``.

| If type is *unit*, the tag *unit* is added automatically to the export.
| If type is *interface*, the tag *interface* is added automatically to the export.
| If type is *mod* and the attribute location points to an existing module documentation, the tag
  *covered* is added automatically to the export.

.. _spec_attr_developer:

developer
---------

| The value can be any string.
| Default value is empty string with is displayed as:

    - ``-`` if specification is struck through
    - ``[missing]`` otherwise

.. _spec_attr_tester:

tester
------

| The value can be any string.
| Default value is empty string with is displayed as:

    - ``-`` if *verification_methods* is *none* or specification is struck through
    - ``[missing]`` otherwise

The attribute is ignored if type is interface **and** ID starts with SMD\_.

.. _spec_attr_verification_methods:

verification_methods
--------------------

Default value:

    - ``off_target`` if type is *srs*, *spec* or *unit* **and** ID starts with SMD\_
    - ``on_target`` if type is *srs*, *spec*, *interface* or *unit* **and** ID starts with SWA\_
    - ``none`` otherwise

The attribute is ignored if type is *interface* **and** ID starts with SMD\_.

.. _spec_attr_verification_criteria:

verification_criteria
---------------------

| Attribute is ignored if type is *interface* and ID starts with SMD\_.
| The value can be any string.
| Default value is empty string with is displayed as:

    - ``[missing]`` if

        - type is *srs* or *requirements* and category is not *input* **and**
        - *tool* is not in *tags* **and**
        - specification is not struck through

    - ``-`` otherwise

.. _spec_attr_comment:

comment
-------

| This attribute is ignored except for input requirements.
| The value can be any string.
| Default value is empty string which is displayed as ``-``.

.. _spec_attr_miscellaneous:

miscellaneous
-------------

| This attribute is ignored except for input requirements.
| The value can be any string.
| Default value is empty string which is displayed as ``-``.

.. _spec_attr_feature:

feature
-------

| This attribute is ignored except for input requirements.
| The value can be any string.
| Default value is empty string which is displayed as ``-``.

.. _spec_attr_change_request:

change_request
--------------

| This attribute is ignored except for input requirements.
| The value can be any string.
| Default value is empty string which is displayed as ``-``.

.. _spec_attr_sources:

sources
-------

*sources* is a comma separated string of relative filenames. It links software detailed design
to the source code.

The filenames must be specified **relative** from the **module root** (identified by the doc-folder
in which the rst-file is placed). Alternatively relative to the rst file itself. These files must
exist, a check is done when building with Sphinx.

This attribute is shown if:

- the attribute is not empty OR
- the type is *unit* OR
- the type is *interface* and the ID starts with SMD\_

Default value is empty string which is displayed as:

- ``-`` if tag *covered* is set or specification is struck through
- ``[missing]`` otherwise

Example:

.. code-block:: rst

    # modules/safety/safeCom/doc/api/public.rst
    # modules/safety/safeCom/include/PublicApi.h

    # relative from module root
    .. unit:: SMD_example_id1
        :sources: include/PublicApi.h

    # relative from current rst file
    .. unit:: SMD_example_id2
        :sources: ../../include/PublicApi.h

.. _spec_attr_refs:

refs
----

| *refs* is a comma separated string of :ref:`specification IDs <spec>`.
  References must **exist** and link to **other specifications**.
| This attribute is not shown directly but integrated to :ref:`spec_additional_upstream_references`
  and :ref:`spec_additional_downstream_references`.

Example:

.. code-block:: rst

    .. spec:: SWA_exampleFeature_id1
        :refs: SMD_exampleModule_id2, SMD_exampleModule_id3

To allow references to non-existing specifications, set the variable
*dox_trace_allow_undefined_refs* in ``conf.py`` to *True*. With this setting, all undefined references
are displayed in red in :ref:`spec_additional_downstream_references` and no warning is printed
during the build.

.. code-block:: python

    dox_trace_allow_undefined_refs = True

To create a list of undefined references, add the directive ``.. undefined_refs::`` e.g. to the
appendix. See :ref:`undefined_refs` for an example.

Undefined references are not :ref:`exported to Dim <spec2dim>`.

.. _spec_attr_location:

location
--------

| Links to the module documentation. Define the path from Sphinx root to module root.
  If the module documentation ``<module root>/doc/index.rst`` exists, an HTML link will be created,
  otherwise the string is displayed as is.
| Default value is empty string which is displayed as:

- ``-`` if specification is struck through
- ``[missing]`` otherwise

Example:

.. code-block:: rst

    .. mod:: SWA_mod_exampleModule
        :location: ecu1/core2/modules/exampleModule

.. _spec_attr_category:

category
--------

This value is usually **not set manually**, it's set by the RST export of Dim. Possible values are
*input*, *system* and *software*. Requirements are handled slightly different depending on the
category, e.g. it affects the :ref:`spec_attr_review_status` visibility.
