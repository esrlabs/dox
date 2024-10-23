.. _sphinx_data_classification:

Data Classification
===================

The default *data classification* is **Confidential** if not specified otherwise in ``conf.py``
like this:

.. code-block:: python

    html_context = {"data_classification_default": "Restricted"}

To overwrite the classification of a document add the following directive at the top of the
rst-file:

.. code-block:: rst

    :data_classification: <classification>

*<classification>* can be one of the following values:

.. list-table::
    :widths: 20 80

    * - .. rst-class:: header-label data-classification-restricted

            Restricted
      - Sensitive information that should not be shared beyond those that need to know.
    * - .. rst-class:: header-label data-classification-highlyconfidential

            Highly Confidential
      - Sensitive Accenture, client, or customer personal data that can only be shared with a
        specific business need.
    * - .. rst-class:: header-label data-classification-confidential

            Confidential
      - Sensitive data intended only to be shared internally across Accenture, or with external
        parties if there is a specific business need.
    * - .. rst-class:: header-label data-classification-unrestricted

            Unrestricted
      - Non-sensitive information that is intended to be generally available to the public.
    * - *None*
      - *The data classification is hidden for the complete documentation.*

Example:

.. code-block:: rst

    :data_classification: Unrestricted

    Some Title
    ==========

    Some text...
