Introduction
============

Dox supports software developers to write **requirements**, **architecture** and **software design**
for their projects. All specification elements can be linked to each other and to source code to get
a full **traceability**.

Dox is the combination of the stand-alone Ruby gem **dim** and the three Python extensions for
`Sphinx <https://www.sphinx-doc.org/>`_ **dox_style**, **dox_util** and **dox_trace**.

Overview
========

For the documentations of the individual tools, please click on the links below.

.. list-table::
    :header-rows: 1

    * - Tool Name
      - Description
    * - `dox_style <dox_style/index.html>`_
      - Provides a default configuration for Sphinx documentations.
        It also checks several style conventions.
    * - `dox_util <dox_util/index.html>`_
      - Collection of small convenience-features for Sphinx documentations.
    * - `dox_trace <dox_trace/index.html>`_
      - Provides specification directives to achieve traceability in Sphinx documentations.
    * - `dim <dim/index.html>`_
      - A light-weight requirements tool based on YAML.

Changelog
=========

See https://github.com/esrlabs/dox/blob/master/CHANGELOG.md.

Contributing
============

Contributions are welcome, please create pull requests! If you want to actively develop these tools,
please contact the owners of https://github.com/esrlabs/dox.

To merge a pull request, two requirements must be fulfilled:

- A code-owner must approve the PR.
- The `automatic checks <https://github.com/esrlabs/dox/actions>`_ must not report any error.

Release Steps
=============

.. note::

    This section is for the code-owners.

- Ensure that all relevant `pull requests <https://github.com/esrlabs/dox/pulls>`_ are merged and
  `issues <https://github.com/esrlabs/dox/issues>`_ are closed.
- Increment the version.

  - Dim: ``<dox root>/dim/version.txt``
  - Sphinx extensions: ``<dox root>/dox_*/dox_*/version.py``

- Extend the change log.

  - Dim: ``<dox root>/dim/documentation/source/pages/changelog.rst``
  - Sphinx extensions: ``<dox root>/dox_*/documentation/source/pages/changelog.rst``

- Adapt the overall documentation in ``<dox root>/documentation``.
- If applicable, update the ``README.md`` files:

  - Overall: ``<dox root>/README.md``
  - Dim: ``<dox root>/dim/README.md``
  - Sphinx extensions: ``<dox root>/dox_*/README.md``

- Push and merge the changes to the ``master`` branch of https://github.com/esrlabs/dox with a
  pull request.
- Build the documentation. Go to ``<dox root>/documentation`` and type:

  .. code-block:: none

        make dist

- Push the output from ``<dox root>/documentation/build/html`` to the ``gh-pages`` branch of
  https://github.com/esrlabs/dox. Please do not delete the empty ``.nojekyll`` file, otherwise the
  HTML style sheets will not work correctly.
- Create the packages.

  - Dim: Go to ``<dox root>/dim`` and type:

    .. code-block:: none

        gem build dim.gemspec

    For more information about Ruby gems see https://guides.rubygems.org.

  - Sphinx packages: Go to ``<dox root>/dox_*`` and type:

    .. code-block:: none

          python -m build

    For more information about Python packages see https://packaging.python.org.

- Upload the packages (accounts and appropriate access rights are required).

  - Dim: Go to ``<dox root>/dim`` and type:

      .. code-block:: none

          gem push dim-toolkit-1.2.3.gem

  - Sphinx packages: Go to ``<dox root>/dox_*`` and type:

      .. code-block:: none

          python -m twine upload dist/*

- Add a new release tag and copy/paste the changelog entries to https://github.com/esrlabs/dox/tags.
