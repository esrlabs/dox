.. _requirements_files:

Requirements Files
==================

Overview
--------

The Dim requirements files are written in YAML format, so they can be processed by every YAML parser.
Dim prints warning message and skips loading of requirements file, if the requirements file is
empty.

Dim expects the following syntax:

.. code-block:: yaml

    document: <name>                    # required, string describing the group or domain of requirements

    metadata: <data>                    # optional string to describe origin, date, version, history, etc.

    enclosed:                          # optional, all those files will be copied when exporting
      - <file1>
      - <file2>
      - <...>

    <id>:                               # must be unique
      - text:                  <value>  # any string, default: ""
      - verification_criteria: <value>  # any string, default: ""
      - feature:               <value>  # any string, default: ""
      - change_request:        <value>  # any string, default: ""
      - type:                  <value>  # one of: requirement (default), information, heading_0, ... heading_100
      - status:                <value>  # one of: draft, valid, invalid
                                        # default: see below
      - tags:                  <value>  # any string, comma separated, default: "",
      - developer:             <value>  # any string, default: ""
      - tester:                <value>  # any string, default: ""
      - verification_methods:  <value>  # one or more of : none, off_target, on_target, manual
                                        # default: see below
      - asil:                  <value>  # one of: not_set (default), QM, QM(A), QM(B), QM(C), QM(D),
                                        #                 ASIL_A, ASIL_A(A), ASIL_A(B), ASIL_A(C), ASIL_A(D),
                                        #                 ASIL_B, ASIL_B(B), ASIL_B(C), ASIL_B(D),
                                        #                 ASIL_C, ASIL_C(C), ASIL_C(D),
                                        #                 ASIL_D, ASIL_D(D)
      - cal:                            # one of: not_set (default), QM, CAL_1, CAL_2, CAL_3, CAL_4
      - review_status:         <value>  # one of: accepted, unclear, rejected, not_reviewed, not_relevant
                                        # default: see below
      - comment:               <value>  # any string, default: ""
      - miscellaneous:         <value>  # any string, default: ""
      - sources:               <value>  # any string, default: ""
      - refs:                  <value>  # any string, default: ""

Attributes
----------

.. _document:

document
++++++++

The **document** name is mandatory and the first hierarchy level for the requirements.

It is valid to specify the same **document** name in different files.
The requirements will be merged into one chapter.

metadata
++++++++

| An optional string to describe the origin of the document, date, version, history, etc.
| If input requirements are converted from a customer format to Dim, the metadata can be added here.

Example:

.. code-block:: none

    metadata: |
              Lastenheft ABC 1.2
              Exported from xy/db/projectX/ABC on Jan 1, 2000

enclosed
++++++++

An optional array to specify all files, which shall be copied when the requirements are exported.
Usually the files are referred in the text section of the requirement with HTML tags:

.. code-block:: yaml

    <html><img src="images/overview.png" width="50%"/></html>

The files must be specified with relative paths. They must not include ``..``.
Use forward slashes ``/``, not backslashes ``\``.

Example:

.. code-block:: yaml

    enclosed:
        - images/overview.png # ok
        - ../somewhere/else/main.png # not ok, Dim will report an error

.. _id:

<id>
++++

Every requirement must have a unique ID.

type
++++

Allowed values are ``requirement`` (default), ``information``, ``heading``, ``heading_0``, ...,
``heading_100``.

text
++++

This is the requirements **text**. Use regular YAML syntax, e.g. for preserving line breaks:

.. code-block:: yaml

    SRS_Feature_Aspect1:
      text: |
            This is a multiline requirement
            with preserved line breaks.

HTML tags are allowed, but they must be surrounded with <html>...</html>:

.. code-block:: yaml

    SRS_Feature_Aspect2:
      text: |
            Now a HTML table follows:
            <html>
              <table>
                <tr>
                  <th>Firstname</th>
                  <th>Lastname</th>
                  <th>Age</th>
                </tr>
                <tr>
                  <td>John</td>
                  <td>Smith</td>
                  <td>40</td>
                </tr>
                <tr>
                  <td>Jane</td>
                  <td>Doe</td>
                  <td>30</td>
                </tr>
              </table>
            </html>
            Now a picture:
            <html><img src="overview.png" width="50%"/></html>

verification_criteria
+++++++++++++++++++++

Can be empty. Describes what is needed to pass a test.

If you have multiple :ref:`verification_methods` defined, list what you expect from which method:

.. code-block:: yaml

    SRS_Abc_Def:
      verification_criteria:        |
                                    off_target: ...
                                    on_target: ...
      verification_methods: off_target, on_target

feature
+++++++

| Can be empty. Describes to what feature the requirement belongs.
| It can be a feature name, ticket ID or any other project specific string.

change_request
++++++++++++++

Can be empty. Describes which change requests are associated with this requirement.

status
++++++

Allowed values are ``draft``, ``valid``, ``invalid``.

Default:

- ``draft`` if **type** is *requirement* or *information*
- ``valid`` if **type** is a heading

tags
++++

Tags are used to specify attributes of the *current* requirement, similar to hashtags on
`X <https://help.x.com/en/using-x/how-to-use-hashtags>`_.

Some suggested tags:

- **covered**: the requirement is fully derived, the references are complete
- **tested**: the requirement is fully tested, no aspect is missing
- **cybersecurity_control**: countermeasure to detect, prevent, reduce, or counteract security risks
- **functional_safety_mechanism**: detect and correct the malfunctions according ISO-26262
- **confidentiality**, **integrity**, **availability**, **authenticity**, **authority**: a specific
  aspects of security
- **legal**: the requirement covers legal interests (compliance)
- **performance**, **memory**: resource restrictions, response and cycle times,
  these requirements are good candidates for stress testing
- **structural**: the requirement specifies how to set up the files, modules and workspace
- **configuration**, **calibration**: requirements which focus on setting up the software
- **established**: proven-in-use feature (may lower the priority for e.g. testing)
- **sys**: used as input for system requirements, this means the input requirement defines system
  behavior and shall link directly to the derived system requirements (only for input requirements)
- **srs**: used as input for software requirements, this means the input requirement is on a black
  box level and shall link to derived software requirements (only for input requirements)
- **swa**: used as input for software architectural specifications, this means the input requirement
  defines specific aspects of the software architecture and shall link directly to the derived
  software architecture specifications (only for input requirements)
- **smd**: used as input for software module designs, this means the input requirement already
  defines specific characteristics of a software module design and shall link directly to the
  derived software module designs (only for input requirements)
- **process**, **test**: used as input for (test) processes, this means the input requirement
  defines a development/project process rather than system/software behavior and shall link directly
  to a (test) process document (only for input requirements)
- **obd**: this means the input requirement has an impact on the onboard diagnosis of the car
- **emission_doc**: the requirement impacts the emission strategy of the car
- **emission_tailpipe**: the requirement has an impact on either the range, consumption, or the
  emission of the car
- **emission_performance**: the requirement has an impact on the cars performance values which are
  specified in the homologation of the car
- **unit**, **interface**: unit specification or architectural interface
- **tool**: the requirement does not specify target software but a tool
- **non_functional**: marks a non-functional requirement

developer
+++++++++

Used to assign the development responsible. It can be any string.

Default:

- ``""`` if **type** is not *requirement* OR **category** is *input* OR a single file is loaded
  without config.
- ``<originator>`` from the config file otherwise.

tester
++++++

Used to assign the testing responsible. It can be any string.

Default:

- ``""`` if **type** is not *requirement*  OR **category** is *input* OR a single file is loaded
  without config OR *process* is in **tags**.
- ``<originator>`` from the config file otherwise.

.. _verification_methods:

verification_methods
++++++++++++++++++++

| The verification methods can be: ``none``, ``off_target``, ``on_target``, ``manual``.
| Multiple values are allowed, comma separated.

- ``off_target`` is used if a requirement is tested without target hardware on a PC, written in e.g.
  rspec, gtest, etc.
- ``on_target`` is used if a requirement is tested on the target hardware
- ``manual`` is used if a requirement is tested with a manual tests e.g. code review etc.
- ``none`` is used if a requirement can/shall not be tested directly.

Default:

- ``none`` if **type** is not *requirement* OR **category** is *input* OR a single file is loaded
  without config OR *process* is in **tags**.
- ``off_target`` if **category** is *module* or **tags** include *tool*.
- ``on_target`` otherwise.

.. _asil:

asil
++++

| The **asil** level. Possible values see above.
| Default is ``not_set``.

.. _cal:

cal
+++

| Specifies the *Cybersecurity Assistance Level*, can be ``QM``, ``CAL_1``, ``CAL_2``, ``CAL_3``,
  ``CAL_4`` and ``not_set``.
| Default is ``not_set``.

review_status
+++++++++++++

Can be ``accepted``, ``unclear``, ``rejected``, ``not_reviewed``, ``not_relevant``.

Default:

- ``not_reviewed`` if **category** is *input* OR a single file is loaded without config.
- ``accepted`` otherwise. It is assumed that files are reviewed in a source control system.

comment
+++++++

Add comments here inclusive name of the commenter and the date.

miscellaneous
+++++++++++++

Can be used to store project specific information. Usually left empty.

sources
+++++++

A comma separated list of source code files. No check for existence.

refs
++++

A comma separated list of all references to other *requirements*. All these references must exist!

A requirement can refer to other requirements from different categories, e.g. a requirement
in `software` category can refer to requirements from `input` or `module` category.
When references occur within the same category, they are understood as flowing from the broader
or more general level (the parent) to the more specific or detailed ones (the derived child).
This means that within a given category, any references are typically understood in terms of how the
overarching requirements relate to the more specialized ones within that same category.

Considering the following requirements from different categories and references shown in the
sample config:

.. code-block:: yaml

   # category system

   SYS_Requirement_1:
      refs: SRS_Requirement_1

   ------------------

   # category software

   SRS_Requirement_1:
      refs: SWA_Architecture_1

   SRS_Requirement_2:
      refs: SRS_Requirement_1

   ------------------

   # category architecture

   SWA_Architecture_1:
      refs: SYS_Requirement_1, SRS_Requirement_2

It looks like there is a cycle in above example, but

.. code-block:: none

    SRS_Requirement_1 -> SWA_Architecture_1 -> SRS_Requirement_1 -> SRS_Requirement_1

is not considered a circular dependency, because

.. code-block:: none

    SWA_Architecture_1 -> SRS_Requirement_2

is an upstream reference. Circular dependency can only occur at same category level.

.. note::

   Following *refs* in a Ruby script might end up in an endless loop, it is recommended
   to follow *upstreamRefs* or *downstreamRefs*, see :ref:`data_access`.

Other Languages
---------------

The attributes ``text``, ``verification_criteria`` and ``comment`` can be added in other languages
with the following syntax:

.. code-block:: yaml

  <attribute name>_<language name>: ...

For example:

.. code-block:: yaml

  SRS_Feature_Aspect:
    text:            This is a requirement.
    text_german:     Das ist eine Anforderung.
    comment:              This is a comment.
    comment_german:       Das ist ein Kommentar.
    comment_french:       C'est un commentaire.

Once used, a language attribute is valid for all requirements. When using the export feature
or the Ruby API the value will be an empty string if not specified otherwise.

Short Forms
-----------

Short forms are possible for *headings* and *information*. Instead of defining the **type**
*heading_0* to *heading_100* and *information*, the strings *h0* to *h100* and *info* can be
prepended to the **text**.

Example:

.. code-block:: yaml

    Module_Abc_Xy1:
      text: Long form
      type: heading_1

    Module_Abc_Xy2:
      text: h1 Shorter form

Usually headings and information have no additional attributes. In this case, they can be written
even shorter:

.. code-block:: yaml

    Module_Abc_Xy3: h1      Even shorter

    Module_Abc_Xy4: info    Multi-line information
                            is demonstrated here.

The whitespaces before and after the type are ignored in both short forms.
