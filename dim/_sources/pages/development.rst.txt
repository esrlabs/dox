.. _development:

Development of Dim
==================

Continuous Integration
----------------------

Dim is developed on GitHub including a **review** and **verification** process.

- Every commit must be approved.
- The unit test of Dim covers 100% of the code. Whenever the code changes, the verifier ensures
  that all tests are passing. In case of a failing test the commit is rejected.

.. _bug_tracking:

Bug Tracking and Feature Planning
---------------------------------

| Bugs and new features are managed with GitHub issues: https://github.com/esrlabs/dox/issues
| In case you have found a bug or if you have feature request, please open a ticket.

Release
-------

After the features and bug fixes including documentation and unit tests are merged to the
repository, a new version of the *Dim* extension can be released.

- Increment the version in ``version.txt``.
- Document the changes in ``documentation/source/pages/changelog.rst``.
- Push the changes to the ``master`` branch of https://github.com/esrlabs/dox.
- Build and upload the documentation to the ``gh-pages`` branch.
- Create a new gem and push it to https://rubygems.org/gems/dim-toolkit.

See also *Release Steps* on https://esrlabs.github.io/dox.

Requirements
------------

The requirements for Dim are written in Dim itself, exported to Sphinx and available in this
documentation. There is also an overview of the mapping between requirement IDs and test cases with
additional statistics generated.

.. toctree::

  requirements/Dim/Requirements
  requirements-generated/mapping
  reqSources
  requirements-generated/stats
  reqConfig
