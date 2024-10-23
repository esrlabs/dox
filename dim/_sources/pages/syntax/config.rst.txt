.. _config_files:

Config Files
============

Dim config files are used

- to load a set of multiple files,
- to define the originators and categories of the files and
- to specify a properties file which influences the :ref:`asil <asil>` and
  :ref:`cal <cal>` values.
- to specify an :ref:`attributes <attributes_file>` file which accepts project specific custom attributes.

Syntax
------

.. code-block:: yaml

    Config:
      - originator: <originator>
        category: <category>
        files: <glob pattern>
      - originator: <originator>
        category: <category>
        files:
          - <glob pattern>
          - <glob pattern>
      - ...
    Properties: File
    Attributes: File


originator
++++++++++

The originator is typically the company name.

category
++++++++

Category must be one of *input*, *system*, *software*, *architecture* and *module*.

They are interpreted in the following top-down order when calculating *upstreamRefs* and
*downstreamRefs*, see :ref:`data_access`:

.. list-table::
    :header-rows: 1

    * - Level
      - Category
      - Full Name
    * - 5
      - input
      - Input Requirement
    * - 4
      - system
      - System Requirement
    * - 3
      - software
      - Software Requirement
    * - 2
      - architecture
      - Architecture Specification
    * - 1
      - module
      - Module / Component Specification

It's important to understand that the requirements within the *module* category are based on those
in the *architecture* category, which in turn are derived from the *software* category, and so on.
This means that *module* is the lowest in the category hierarchy, while *input* holds a higher
position.

files
+++++

Files can be defined as a string or as an array of strings containing glob patterns with relative
path names. The patterns must not include ``..``. Use forward slashes ``/``, not backslashes ``\``.

Properties
++++++++++

Defines the :ref:`property_files`.

Attributes
++++++++++

Defines the :ref:`attributes_file`.

Example
-------

.. code-block:: yaml

    Config:
      - originator: Accenture
        files:
          - "modules/**/*.dim"
          - "safety_modules/**/*.dim"
        category: module
      - originator: CustomerA
        files: "input/<CustomerA>/**/*.dim"
        category: input
    Properties: "properties.yaml"
    Attributes: "attributes.dim"

Software Requirements
---------------------

Whenever `category` in the config file is set to ``software``, Dim checks the following naming
conventions:

- IDs and the document name must start with ``SRS``.
- IDs must be named ``SRS_<feature-name>_<topic-name>``. They must have exactly two underscores.
- Document must be named ``SRS_<feature-name>``. It must have exactly one underscore.
- *<feature-name>* and *<topic-name>* must only contain alphanumeric characters and hyphens (-).

In case of violation, Dim will report an error exit the process.

For legacy software requirements, you can disable this check by setting the option
``disable_naming_convention_check`` to `yes` for the respective originator in
the config file. Default for ``disable_naming_convention_check`` is `no`.

Example:

.. code-block:: yaml

   Config:
     - originator: Accenture
       files:
         - sample_module.dim
         - testing_module.dim
       disable_naming_convention_check: yes # Dim will skip the SRS naming convention checks for all files from this originator
       category: software
     - originator: Customer
       files: # Dim will check for SRS naming conventions
         - software_sample.dim
         - hardware_sample.dim
       category: software

Example requirements file with valid document name and ID:

.. code-block:: yaml

   document: SRS_display

   SRS_display_refresh-rate:
      text: Refresh rate shall be 90 Hz.
