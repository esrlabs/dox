.. _command_line_interface:

Command Line Interface
======================

General Arguments
-----------------

- ``--help`` prints the usage with all available arguments
- ``--version`` prints the version
- ``--license`` prints the license

Subcommands
-----------

Dim supports different subcommands:

.. code-block:: text

    dim <subcommand> <parameters>

All available subcommands with the additional parameters are described below.

check
+++++

This checks all input files if they are valid, e.g. if the **refs** can be resolved.

-i FILENAME, \-\-input FILENAME
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``-i`` specifies a :ref:`requirements file <requirements_files>` or
:ref:`config file <config_files>`.

Usually requirements are loaded via a config file which specifies the category and the originator
for the requirements. If a requirements file is loaded directly, the category is set to
*unspecified* and the originator to an empty string.

Example:

.. code-block:: text

    dim check -i project/reqs/config.dim

-a FILENAME, \-\-attributes FILENAME
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``-a`` specifies a :ref:`custom attributes file <attributes_file>`.

An attributes files is usually specified in the :ref:`config file <config_files>`. Loading a
requirements file with custom attributes directly would lead to an error. To avoid that, the
attributes file can also be specified on the command line.

If the config file has a reference to custom attributes AND an attributes file is specified using
this command line parameter, then attributes from both references are taken into consideration.
If the same attribute is present in both files, the attributes loaded from config file will be
prioritized.

If a single requirements file without this parameter is loaded, then Dim searches for a file named
*attributes.dim* recursively, starting from location of the requirements file till the root directory
is reached. If such a file is found, then the custom attributes are loaded from that file.

\-\-allow-missing
~~~~~~~~~~~~~~~~~

When loading only a part of the requirements files, references may not be resolvable, which would
lead to an error. To suppress them, use ``--allow-missing``. This is only for developing
purposes. An official export must be done without this parameter.

While :ref:`formatting <subcommand_format>`, this parameter is automatically set.

\-\-no-check-enclosed
~~~~~~~~~~~~~~~~~~~~~

When Dim contains enclosed files, it checks for the presence of those files. A missing file leads
to an error. To skip the enclosed files check, use ``--no-check-enclosed``.

\-\-silent
~~~~~~~~~~

When this option is set, Dim will not print any info logs on the screen. Errors and warnings will
still be printed to inform the user what went wrong during the operations.

.. _subcommand_format:

format
++++++

This subcommand :ref:`formats <format>` requirements files. Dim sets the `allow-missing` parameter
automatically when formatting the documents, which means Dim will not warn about missing references.

``format`` implicitly executes the consistency ``check``. All ``check`` parameters can also be used
for ``format``.

All existing YAML comments are removed during formatting.

\-\-output-format FORMAT
~~~~~~~~~~~~~~~~~~~~~~~~

- ``in-place``: By default, requirements files are changed in-place.
- ``extra``: To create extra files next to the original files (with the ending *.formatted*) use
  this output format.
- ``check-only``: Checks the files without changing them. If the formatting is not correct,
  Dim exists with an exit code != 0.
- ``stdout``: This is to support the inline formatting in IDEs. Any IDE which works with STDIN and
  STDOUT can use this flag to support code formatting within the IDE.


More details about `stdout`:

It is assumed that the requirements file is valid. As binary input is read from STDIN, this output format
skips the check for enclosed files and refs. The formatted output will be sent to STDOUT, from
where the IDE is supposed to read.

When output format is set to `stdout`, Dim automatically sets the following parameters:

- `allow-missing`
- `no-check-enclosed`
- `silent`

Config files are not supported.

The following example shows how to use this feature with ``Vim``, assuming that the `vim-autoformat`
plugin is already installed:

- First, add this to the `.vimrc` file:

  .. code-block:: text

    let g:formatdef_dimtool = '"dim format --output-format stdout"'
    let g:formatters_dim = ['dimtool']

- After the file has been loaded into Vim, format the file like this:

  .. code-block:: text

    :Autoformat dim

export
++++++

Requirements can be exported to different formats. The output can be made available to
other tools or third-parties.

``export`` implicitly executes the consistency ``check``. All ``check`` parameters can also be used
for ``export``.

-o FOLDER \-\-output FOLDER
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Specifies the output folder. Every document with its enclosed files will be exported to a subfolder.
If the folders do not exist, they will be created. Existing files will be overwritten.

-f FORMAT \-\-format FORMAT
~~~~~~~~~~~~~~~~~~~~~~~~~~~

FORMAT can be *rst*, *csv* and *json*.

| *csv* can be used for e.g. exporting to other requirements tools.
| *rst* output is input for a Sphinx documentation build which can create HTML pages.

\-\-filter FILTER
~~~~~~~~~~~~~~~~~

The output can be filtered with quite natural conditions, e.g.

.. code-block:: text

    # filter entries which are requirements and have CAN in the text.
    --filter "type == requirement && text =~ /CAN/"

stats
+++++

This prints some nice stats about requirements, per owner/originator, per document, etc.

``stats`` implicitly executes the consistency ``check``. All ``check`` parameters can also be used
for ``stats``.
