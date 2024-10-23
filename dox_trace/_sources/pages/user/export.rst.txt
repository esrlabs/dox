.. _spec2dim:

Export to Dim Files
===================

To enable the export, add the configuration option *dox_trace_dim_root* to ``conf.py``. This option
specifies the path to the *Dim* export folder. If the option is not set, the export is disabled.

Example:

.. code-block:: python

    dox_trace_dim_root = "../some/folder"

Only the types ``srs``, ``spec``, ``mod``, ``interface`` and ``unit`` are exported.
When exporting to Dim, a folder is injected into the path depending on the first element of the ID,
either ``srs``, ``swa`` or ``smd``:

    - ``<dox_trace_dim_root>/srs/<same folder structure>/*.dim``
    - ``<dox_trace_dim_root>/swa/<same folder structure>/*.dim``
    - ``<dox_trace_dim_root>/smd/<same folder structure>/*.dim``

All Dim files in ``<dox_trace_dim_root>/<type>`` will be deleted prior to the export, except for
categories which have no specification to export. E.g. if no ``srs`` is specified, the folder
``<dox_trace_dim_root>/srs`` will not be deleted.

The following data is extracted:

- The **document** name is derived from the ID of the first specification of the RST file, e.g.
  *SMD_moduleName_Spec1* becomes *SMD_moduleName*.
- The IDs of the specifications will be used as **Dim IDs**.
- The **content** and the attribute **verification_criteria** are replaced in the export with:
  *See Sphinx documentation.*
- The **tags** *unit* and *interface* are added to *tags* for unit and interface specifications
  and exported accordingly.
- All other **attributes** are exported as specified or with their default values.

Notes:

- Usually, the exported files are not committed.
- They do not follow the Dim formatting scheme.
