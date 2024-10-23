.. _ruby_interface:

Ruby Interface
==============

It is possible to access the data via Ruby. All default fields are already evaluated.

Loading
-------

Instantiate a loader and call the ``load()`` method. ``load()`` offers three arguments:

- ``file:`` Either a requirements or a config filename. Mandatory argument.
- ``attributes_file:`` Project specific custom attributes filename, Optional, defaults to empty filepath.
- ``allow_missing`` Ignore unresolved references if set to *true*. Optional, defaults to *false*.
- ``silent`` Suppress logging output while loading files if set to *true*. Optional, defaults to
  *true*.
- ``no_check_enclosed`` Skips the enclosed file check. Optional, defaults to *false*.

Example:

.. code-block:: ruby

    require 'dim/loader'

    l = Dim::Loader.new
    l.load(file: "module.dim", attributes_file: "attributes.dim", allow_missing: true, silent: false)

.. _data_access:

Data Access
-----------

After loading, all data is accessible via the member variable *requirements* of the loader. This
variable is a hash, the keys are the IDs of the requirements, the values the requirement objects.

A requirements object has the following getters:

- All **attribute names** from :ref:`requirements_files` to access the data, like *text*,
  *review_status*, etc.
- **document**: the document name used in the :ref:`requirements_files`
- **id**: for convenience, same as the key in the *requirements* hash
- **origin**, **category**: from config file
- **filename**, **line_number**: to print error messages, etc.
- **existingRefs**: array of ref-IDs which really exists (useful if `allow_missing` was set to
  *true*)
- **backwardRefs**: array of ref-IDs which reference *this* requirement
- **upstreamRefs**: array of IDs from refs to higher category level plus
  backward-refs from higher or same category level
- **downstreamRefs**: array of IDs from refs to lower or same category level plus
  backward refs from lower category

The following table shows the return types of the getter methods:

.. list-table::
   :widths: 50, 50
   :header-rows: 1

   * - Strings
     - Array of Strings
   * - asil
     - backwardRefs
   * - cal
     - developer
   * - change_request
     - downstreamRefs
   * - comment
     - existingRefs
   * - feature
     - refs
   * - filename
     - sources
   * - id
     - tags
   * - miscellaneous
     - verification_methods
   * - document
     - tester
   * - origin
     -
   * - review_status
     -
   * - status
     -
   * - text
     -
   * - type
     -
   * - verification_criteria
     -

Some examples:

.. code-block:: ruby

    require 'dim/loader'

    l = Dim::Loader.new
    l.load(...)

    requirements_text = l.requirements["myId"].text
    modules = l.requirements.values.map {|r| r.document}.uniq
    valid_notRejected_Reqs = l.requirements.values.select do |r|
      r.type == "requirement" && r.status == "valid" && r.review_status != "rejected"
    end
    devMyCompany = reqs.select {|r| r.developer.include?("MyCompany")}
    reqsWithRefs = reqs.select {|r| !r.refs.empty? }

The **metadata** is available via the member variable *metadata* of the loader.
This variable is a hash with document name as key and the metadata as string value.

Example:

.. code-block:: ruby

    require 'dim/loader'

    l = Dim::Loader.new
    l.load(...)

    puts l.metadata["document"]


Convenience Methods
-------------------

String Lists
++++++++++++

Dim extends the Ruby String class with the following methods which can be also used by custom
scripts:

- | ``cleanSplit`` returns an array of the elements without leading and trailing whitespaces
  | Example: :code:`"a,a,b    ,,  c".cleanSplit() == ["a", "a", "b", "", "c"]`

- | ``cleanArray`` same as cleanSplit, but without empty elements
  | Example: :code:`"a,a,b    ,,  c".cleanArray() == ["a", "a", "b", "c"]`

- | ``cleanUniqArray`` same as cleanArray, but also removes duplicates
  | Example: :code:`"a,a,b    ,,  c".cleanArray() == ["a", "b", "c"]`

- | ``cleanString`` removes empty elements, leading and trailing whitespaces
  | Example: :code:`"a,a,b    ,,  c".cleanString() == "a, a, b, c"`

- | ``cleanUniqString`` same as cleanString but also removes duplicates
  | Example: :code:`"a,a,b    ,,  c".cleanUniqString() == "a, b, c"`

- | ``addEnum`` adds another element to the list and makes all elements in the list unique
  | Example: :code:`"a, b, c, a".addEnum("d") == "a, b, c, d"`

- | ``removeEnum`` removes all enums with a specific value from the list
  | Example: :code:`"a, b, c, a".removeEnum("a") == "b, c"`

.. _convenience_calculations:

Calculations
++++++++++++

- ``safety_relevant?`` returns

   - *true* if the *asil* in the requirement is neither *QM* nor *not_set*,
   - otherwise *false*.

- ``security_relevant?`` returns

  - *true* if the *cal* in the requirement is neither *QM* nor *not_set*,
  - otherwise *false*.

.. _original_data:

Original Data (Expert Usage)
----------------------------

For special expert usages, the loader also provides a member variable *original_data*.
This is a hash of **filenames** to the **data read from the files** via YAML library.

Note, that a few things are nevertheless changed and not completely "original":

- converting short forms to regular forms
- converting  non-breaking spaces to regular spaces
- removing duplicate entries from verification_methods and tags
- stripping strings
- adding non-existing attributes of a requirement as empty strings

Example:

.. code-block:: yaml

    # filename.dim
    document: myModule

    myId:
      text: abc

.. code-block:: ruby

    # script
    require 'dim/loader'

    l = Dim::Loader.new
    l.load(...)

    l.original_data["filename.dim"]["module"] == "myModule"
    l.original_data["filename.dim"]["myId"]["text"] == "abc"

Use the formatter to write changed data back to the requirements files:

.. code-block:: ruby

    require 'dim/commands/format'

    l = Dim::Loader.new
    l.load(...)

    l.original_data ...

    formatter = Dim::Format.new(l)
    formatter.execute
