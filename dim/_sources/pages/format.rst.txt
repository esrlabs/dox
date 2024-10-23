.. _format:

Formatting
==========

Dim is based on `YAML <https://yaml.org/>`_, so technically the only hard constraint is that the
Dim files have to follow the YAML standard. Please have a look at the YAML standard,
especially how to write strings over multiple lines, e.g.:

.. code-block:: yaml

    text: |
          The vertical bar preserves line break in this paragraph.
          - line 1
          - line 2

    text: >
          The greater-than sign removes
          the line
          breaks.


Additionally, to improve readability and editing the following formatting rules are highly
recommended.
These formatting rules (and some more) can be applied and checked with the subcommand
:ref:`subcommand_format`.

Indentation
-----------

- Do not indent **<id>**, **document**, **enclosed**.
- Indent attribute keys like **text** or **tags** by 2 characters.
- Indent **text** value by 28 characters.
- Indent **verification_criteria** value by 32 characters.

Example:

.. code-block:: yaml

    document: My module

    SRS_Feature_Heading:        h2 My heading

    SRS_Feature_Req1:
      text:                     Some text.
      tags: tested

    SRS_Feature_Req2:
      text:                     |
                                Some multiline text is
                                added here.
      verification_criteria:        To verify do something.
      tags: availability

    SRS_Feature_Req3:
      text:                     Again another bla bla.
      verification_criteria:        To verify do some other stuff.
      tags: tested

Arrays
------

| Arrays are **intentionally not supported** to keep the syntax easy.
| For all fields with multiple values, Dim reads the string and splits it at ``,``` characters.

In most cases it's fine to simply write a comma separated string:

.. code-block:: yaml

    SRS_Feature_Req:
      tags: availability, confidentiality

In some cases like listing a lot of references, it's recommended to use the character ``>``,
which removes the line breaks and the output is a single-line string again:

.. code-block:: yaml

    SRS_Feature_Req:
      refs: >
            SRS_AnotherFeature_Req1,
            SRS_AnotherFeature_Req2,
            SRS_AnotherFeature_Req3,
            SWA_Something_Else

Empty Lines
-----------

Add one empty line between requirements.

Encoding
--------

To ensure that special characters such as *µ*, *°* or umlauts are correctly displayed, Dim
files need to be encoded in **utf-8**. Other encodings such as ANSI, Windows1250, ISO8859-1 etc.
are possible but some characters may be automatically converted to *?*.
