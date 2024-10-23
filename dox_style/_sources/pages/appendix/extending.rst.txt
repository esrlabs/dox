Extending Checks
================

.. note::

    This is a for maintainers of this extension.

To extend the checks, inherit from the ``Check`` class and create an according ``Finding``.
Have a look at ``dox_style/checks/dummy.py`` for an easy example.

Finally you need to register your check in the ``dox_style/checks/main.py`` by adding it to the
``all_checks`` dictionary. The keys of this dictionary are used to generate the corresponding
configuration options for ``conf.py``.
