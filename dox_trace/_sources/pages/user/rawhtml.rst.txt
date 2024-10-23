HTML in Attributes
==================

Custom Roles
------------

Textual attributes and the content of specifications are parsed with Sphinx, so it is possible to
use any predefined role, which can be interpreted as HTML:

**RST**:

.. code-block:: rst

    .. requirement:: Req1
        :feature: -> feature1 :custom-role:`<br>` -> feature2

        This is the :custom-role:`<b>` requirement :custom-role:`</b>`.

This is **not recommended** for self-written specifications.

Sphinx Syntax
-------------

For self-written specifications, use regular Sphinx syntax:

**RST**:

.. code-block:: rst

    .. requirement:: Req2
        :feature: -> feature1
                  -> feature2

        This is the **requirement**.

**HTML**:

.. requirement:: Req2
    :feature: -> feature1
              -> feature2

    This is the **requirement**.

Auto-Generation
---------------

Specifications may be auto-generated like done by **Dim**. If an attribute or the content starts
with ``:raw-html:``` and ends with `````, the string between the backticks is treated as HTML. Is it
not a real role, which means there is no need to define this role in Sphinx, just use this pattern:

**RST**:

.. code-block:: rst

    .. requirement:: Req3
        :feature: :raw-html:`<br> -> feature1 <br> -> feature2`

        :raw-html:`This is the <b>requirement</b>.`

**HTML**:

.. requirement:: Req3
    :feature: :raw-html:`<br> -> feature1 <br> -> feature2`

    :raw-html:`This is the <b>requirement</b>.`
