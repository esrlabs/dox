weak
====

*Sphinx* is based on *docutils*. In *docutils* it's up to the user to decide whether a missing label
shall result in a warning or not. *Sphinx* does not support this feature.

This extension provides references which behave like regular references but by default missing
labels are ignored:

.. list-table::
    :widths: 50 50
    :header-rows: 1

    * - rst
      - html
    * -
        - :weakref:`refDoesNotExist`
        - :weakref:`dox_util`
        - :weakref:`this extension <dox_util>`

      - .. code-block:: rst

            - :weakref:`refDoesNotExist`
            - :weakref:`dox_util`
            - :weakref:`this extension <dox_util>`
    * -
        - :weakdoc:`docDoesNotExist`
        - :weakdoc:`../../index`
        - :weakdoc:`this extension <../../index>`

      - .. code-block:: rst

            - :weakdoc:`docDoesNotExist`
            - :weakdoc:`../../index`
            - :weakdoc:`this extension <../../index>`

To globally re-enable the warnings, add the following line to ``conf.py``:

.. code-block:: python

    enable_weak_warnings = True
