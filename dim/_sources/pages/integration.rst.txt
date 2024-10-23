Integration
===========

.. _compatibility:

Compatibility
-------------

- Dim requires at least Ruby 2.7. It does not use any special third-party library, the standard
  installation is enough.
- The officially supported platforms are Windows, Linux and macOS.

Folder Structure
----------------

| Dim can handle almost any folder structure specified through the :ref:`config_files`.
| One of the few constrains is to place the :ref:`requirements_files` not above the config file.

Use the following structure as a guidance, tailor it depending on the project specific needs:

.. code-block:: none

    req
      input
        customerA
          lastenheft1
            Requirements.dim
            data
              image1.png
              image2.png
          lastenheft2
            Requirements.dim
            data
              image3.png
              image4.png
      srs
        feature1
          Requirements.dim
          data
            image5.png
            image6.png
        feature2
          Requirements.dim
      config.dim

- Choose a root folder for the requirements, here ``req``.
- Add a config file there, like ``config.dim``.
- Create folders for every category, e.g. ``input`` and ``srs``.
- `Input Requirements` may be originated by different customers, so create subfolders for every
  customer, for example ``customerA``.
- Create another level of subfolders for the requirements files, e.g. ``lastenheft1`` or
  ``feature1``.
- Place the requirements files into these folders. The ending should be ``*.dim``.
- Put any enclosed file to a ``data`` subfolder.


File Structure
--------------

The file must be compliant to the specified syntax for the :ref:`config_files` and
:ref:`requirements_files`.

Some general advices:

- Use headings and subheadings to make especially large documents more readable.
- Avoid more than four heading levels.
- Don't use YAML comments, they will be removed when using the Dim formatter.

.. _integration_verifier:

Verifier
--------

The **check** command must be added to a project specific verifier which checks the changes before
they are merged into the repository. If the exit code is not 0, the verifier must reject the commit.
The commit must be also rejected if Dim hangs and is terminated due to a timeout, etc.

This way it's ensured that always syntactically correct and consistent files are merged to the
repository. This also helps to prevent safety and security issues.

.. _integration_export:

Export
------

When exporting to another format, e.g.

- to CSV as input for a requirements exchange with the customer or
- to RST as input for a Sphinx build,

review the exported data or the result of the tool using the exported data for correctness.

.. _integration_stats:

Statistics
----------

When using the ``stats`` subcommand, review the results for correctness by doing a sanity check.
This shall avoid that wrong or incomplete files are loaded without recognizing it.

.. _integration_scripting:

Scripting
---------

When using a script to access the Ruby API, perform at least one of the following reviews:

- Review the script for correctness.
- Review the outcome of the script for correctness.

Depending on the complexity of the script, unit tests or a complete tool evaluation / qualification
might be necessary.

Bugs
----

Bugs must be tracked on regular basis, see also :ref:`bug_tracking`. Check whether the reported
bugs have an impact on the project and take appropriate actions like updating Dim in that project.

Version
-------

It must be ensured that only the correct (qualified) version of this tool is used.

- Log the version of Dim in the official CI-jobs and
- compare this version with the version specified for the project.

Training
--------

| All users of Dim must read this documentation.
| They have to be trained in the usage of this tool to fully understand all features which are needed
  for their work.
