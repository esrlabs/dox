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

Bugs and new features are handled with GitHub issues.
In case you have found a bug or if you have feature request, please open a ticket.

Release
-------

Merging a change to GitHub does not mean it's automatically available for the users. A new Dim
version must be released explicitly:

    - Increment the version in ``version.txt``.
    - Document the changes in ``documentation/source/pages/changelog.rst``.
    - Push these changed files to GitHub.
    - After successful merge, build the gem:

      .. code-block::

            gem build dim.gemspec
    - Push the gem to RubyGems, e.g.:

      .. code-block::

            gem push dim-toolkit-1.2.3.gem --host https://rubygems.org/ --key ...
    - Push the documentation to https://esrlabs.github.io/dox/dim.
    - Add a new release tag.

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
