.. _version_handling:

Version Handling
================

This page describes two ways how multiple versions of requirements can be managed:

1. Postfixing requirement IDs with the version.
2. Separating requirements based on version.


Postfixing Requirement IDs
--------------------------

A version number can be appended to any requirement ID.
For example, the requirement ID ``SRS_Req_Abc`` for version 1 could be represented as
``SRS_Req_Abc-v1``. This approach ensures that each version of a requirement is uniquely
identifiable.

When the requirement changes, a new version can be created in same requirements file, adjacent to
the original requirement, e.g. ``SRS_Req_Abc-v2``.

.. code-block:: text

    SRS_Req_Abc-v1:
      text: All software modules shall implement the security features.

    SRS_Req_Abc-v2:
      text: All software modules shall implement the security features
            along with the safety measures.

If there is no change in a requirement, then creating new version for requirement can be skipped.

A single requirements file contains all versions of the requirement and can be used for reviews
and other workflows.

To export a specific version of the requirements to a different location, a filter script can be
applied. This script can select only the desired version of each requirement, remove the version
postfixes, and export the filtered requirements.

Separating Requirements In Different Files
------------------------------------------

Whenever a requirement changes, a new requirements file can be created with the version specified in
the filename.

E.g., if requirements in ``featureX.dim`` need to be changed, the file is copied to
``featureX_v2.dim`` and the changes are made in the new file.

This method will result in duplicate requirements across multiple requirements files.
To manage these duplicates, all files can be loaded in a script, a filter applied and finally only
specific versions of the requirements are selected.
