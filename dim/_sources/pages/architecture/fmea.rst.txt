FMEA
====

The FMEA is done on the "first zoom level" of the architecture,

- the :ref:`main workflow of the command line <workflow_main>` usage and
- the :ref:`main workflow of the scripting <workflow_scripting_main>` usage.

The relevant elements are annotated by oval labels, see also the :ref:`diagram legend <legend>`.

Fault Model
-----------

The following analysis is based on this generic *fault model* for activity diagrams:

.. list-table::
   :header-rows: 1
   :widths: 20 15 65
   :width: 100%

   * - Element Type
     - Error ID
     - Generic Error Description
   * - Data storage
     - DS1
     - Stored data changed before read operation
   * -
     - DS2
     - New data not stored / keeps old data / stuck at specific value
   * - Data flow
     - DF1
     - Transferred data changed
   * -
     - DF2
     - Transferred data lost
   * -
     - DF3
     - Data stored at / read from wrong location in data store
   * -
     - DF4
     - Data transferred to wrong data store
   * - Processing
     - PR1
     - Calculates wrong results
   * -
     - PR2
     - Processing is skipped
   * -
     - PR3
     - Processing too slow/fast
   * - Control flow
     - CF1
     - Control flow stops
   * -
     - CF2
     - Control flow proceeds to wrong process

If more than one error is identified for the same element with the same error ID, a counter is
added, e.g. `PR1.1`, `PR1.2`, etc.

In the following sections, references to files are shown which end with ``_spec.rb``. These files
are test files which can be found in the ``spec`` folder of the *Dim* tool, e.g.
``<Dim root>/spec/options_spec.rb``.

Generalized Errors
------------------

The following errors are analyzed generically and not on architectural element level.

.. csv-table::
   :file: fmea/general.csv
   :header-rows: 1
   :widths: 12 30 32
   :width: 100%
   :delim: ,

.. _fmea_command_line_workflow:

Command Line Workflow
---------------------

This analysis is done on the :numref:`workflow_main_fig` with the :ref:`use_cases` in mind.

.. csv-table::
   :file: fmea/dynamic.csv
   :header-rows: 1
   :widths: 5 5 25 35 25
   :width: 100%
   :delim: ,

.. _fmea_scripting_workflow:

Scripting Workflow
------------------

This analysis is done on the :numref:`scripting_main_fig` with the :ref:`use_cases` in mind.

The basic idea (loading, processing, writing) is the same as in the
:ref:`fmea_command_line_workflow`. Therefore references to the analysis of that workflow are added
here to avoid unnecessary duplication.

.. csv-table::
   :file: fmea/scripting.csv
   :header-rows: 1
   :widths: 5 5 25 35 25
   :width: 100%
   :delim: ,
