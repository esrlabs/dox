
.. _integration:

Integration
===========

Compatibility
-------------

- Requires at least Python 3.8.
- Requires at least Sphinx 6.2.
- *dox_trace* is optimized for the  `Read the Docs Sphinx Theme <https://sphinx-rtd-theme.readthedocs.io/>`_.
  For convenience, use the *dox_style* extension enhances the original *RTD theme* by some nice
  features.
- The officially supported platforms are *Windows*, *Linux* and *macOS*.

Configuration
-------------

To use the dox_trace extension in your workspace, you have to reference it in ``conf.py``:

In the following example, the *dox_trace* extension was copied into an ``_ext`` folder, see also
:ref:`installation`.

.. code:: python

    EXTENSION_ROOT = Path('_ext')
    sys.path.extend([str(path.resolve()) for path in EXTENSION_ROOT.glob('*')])
    extensions = [
        ...,
        'sphinxcontrib.jquery',
        'dox_trace'
    ]

*dox_trace* is using jQuery. ``sphinxcontrib.jquery`` needs to be added as extension to ``conf.py``
as well.

The extension can be configured with the following parameters:

- ``dox_trace_custom_attributes``: definition of :ref:`custom attributes <dim_custom_attr>`
- ``dox_trace_allow_undefined_refs``: allowing :ref:`references <spec_attr_refs>` to non-existing
  targets
- ``dox_trace_allow_deprecated``: enabling backward compatibility for
  :ref:`specification <spec_types>` types
- ``dox_trace_security_backward``: enabling backward compatibility for
  :ref:`security <backward_compatibility_security>` attribute
- ``dox_trace_test_setups_backward``: enabling backward compatibility for
  :ref:`test_setups <backward_compatibility_test_setups>` attribute
- ``dox_trace_dim_root``: :ref:`exporting to Dim files <spec2dim>`

Folder Structure
----------------

There is no limitation regarding the folder structure from tooling perspective, but please follow
project specific guidelines.
When exporting to Dim, the Sphinx folder structure is used to create Dim files, e.g.:

.. code:: none

  a/b/c.rst  -->  a/b/c.dim

File Structure
--------------

There is also no limitation regarding the file structure, but again, please follow project specific
guidelines.

| The IDs for *srs* must start with ``SRS_<string>_<string>``.
| The IDs for *spec* must start with ``SMD|SWA_<string>_<string>``.
| The IDs for *mod* and *interface* must start with ``SWA_<string>_<string>``.
| The IDs for *unit* must start with ``SMD_<string>_<string>``.

All IDs must contain exactly two ``_``.

In earlier version of this extensions, the rules were less strict. It was only checked if the ID
starts with ``SMD|SWA_``. To re-enable this behavior, set the config variable
*dox_trace_tolerant_naming_convention* in *conf.py* to *True*:

.. code-block:: python

    dox_trace_tolerant_naming_convention = True

When exporting to Dim, a folder is injected into the path depending on the first element of the ID,
either ``srs``, ``swa`` or ``smd``.

Example:

.. code:: none

  <documentation root>/a/b/c.rst  -->  <Dim export root>/swa/a/b/c.dim

Specification Structure
-----------------------

Follow the syntax described in the *User Documentation*. dox_trace will automatically check if the
syntax is correct during the build except attributes which have fixed enums values like *status* or
*asil*. These values are checked when exporting to Dim and running the ``dim check``.

Verifier
--------

Include the documentation build in a verifier (no incremental build). Also export the specifications
to Dim files and run the ``dim check``. The verifier must reject the commit if:

- the exit code is not 0 for Sphinx / Dim
- Sphinx / Dim hangs and is terminated due to a timeout

This ensures that only syntactically correct and consistent files are merged to the repository.
It also helps to prevent safety and security issues.

Review
------

Always review the HTML output to check that the specifications are displayed as expected.

Always perform a sanity check of the Dim export, e.g. are files written, is something obvious
missing and do some spot checks.

Official Builds
---------------

When building the official documentation (with or without a Dim export) always perform a complete
build, not an incremental build. Make sure that the ``build`` folder does not exist before starting
the build.

Bugs
----

Bugs must be tracked on regular basis, see also :ref:`bug_tracking`. Evaluate if the reported
bugs have an impact on your project and take appropriate actions like updating *dox_trace* in that
project to a newer version.

Version
-------

It must be ensured that only the correct (qualified) version of this tool is used.

- Log the version of *dox_trace* in the official CI-jobs.
- Compare this version with the version specified for the project.

Training
--------

| All users of *dox_trace* must read this documentation.
| They have to be trained in the usage of this tool to fully understand all features which are needed
  for their work.
