.. _sphinx_build_type:

Build Type
==========

For local builds, an ``UNOFFICIAL BUILD`` label is automatically added to the footer, because it's
not ensured that these builds are reproducible due to potential local changes.

For official builds, this label can be replaced with an ``official build`` label by manually setting
the environment variable *OFFICIAL_BUILD* to *1*.
This can be done directly when calling make:

.. code-block:: none

    make html OFFICIAL_BUILD=1
