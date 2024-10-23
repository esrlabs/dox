.. _dox_trace_configuration:

Configuration
=============

To include the configuration options, add the ``.. dox_trace_config::`` directive to your
documentation, e.g.:

.. literalinclude:: ../appendix/config.rst
    :language: rst

*Type*, *ID* and the content are always shown. With ``.. dox_trace_config::``, it is possible to
change the **visibility** of the other attributes as follows:

- *Show all*
- *Hide empty*
- *Hide empty and "[missing]"*
- *Hide all*

For this documentation the :ref:`configuration <dox_trace_config>` can be found in the appendix.

Note, the setting is **stored globally for each project** (based on the *project* value in
conf.py) in the browser-storage. Due to security reasons the browser-storage is bound to
*protocol://host:port*, this means a local build and a documentation on a server can have a
different setting.
