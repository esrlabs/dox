.. _sphinx_table_colors:

Colored Tables
==============

| Use a list table with class ``colored`` and add containers for every cell which shall have a
  color.
| Optionally specify ``spaced`` for a cell margin or ``centered`` to align the text horizontally in
  the middle:

.. code:: rst

    .. list-table::
        :class: colored [spaced] [centered]

        * - .. container:: <color>-cell

                <text>
          - .. container:: <color>-cell

                <text>

Color example:

.. code:: rst

    .. list-table::
       :header-rows: 1
       :class: colored centered spaced

       * - Heading
         - .. container:: green-cell

                Green
         - .. container:: yellow-cell

                Yellow
         - .. container:: orange-cell

                Orange
         - .. container:: red-cell

                Red
         - .. container:: blue-cell

                Blue
         - .. container:: white-cell

                White
         - .. container:: black-cell

                Black
         - .. container:: grey-cell

                Grey
       * - Regular Row
         - .. container:: green-cell

                Green cell with some more words
         - .. container:: yellow-cell

                Yellow
         - .. container:: orange-cell

                Orange
         - .. container:: red-cell

                Red
         - .. container:: blue-cell

                Blue
         - .. container:: white-cell

                White
         - .. container:: black-cell

                Black
         - .. container:: grey-cell

                Grey

.. list-table::
   :header-rows: 1
   :class: colored centered spaced

   * - Heading
     - .. container:: green-cell

            Green
     - .. container:: yellow-cell

            Yellow
     - .. container:: orange-cell

            Orange
     - .. container:: red-cell

            Red
     - .. container:: blue-cell

            Blue
     - .. container:: white-cell

            White
     - .. container:: black-cell

            Black
     - .. container:: grey-cell

            Grey
   * - Regular Row
     - .. container:: green-cell

            Green cell with some more words
     - .. container:: yellow-cell

            Yellow
     - .. container:: orange-cell

            Orange
     - .. container:: red-cell

            Red
     - .. container:: blue-cell

            Blue
     - .. container:: white-cell

            White
     - .. container:: black-cell

            Black
     - .. container:: grey-cell

            Grey

Layout example:

.. code:: rst

    .. list-table::
        :class: colored

        * - .. container:: orange-cell

                colored
          - .. container:: green-cell

                text

    .. list-table::
        :class: colored spaced

        * - .. container:: orange-cell

                colored and spaced
          - .. container:: green-cell

                text

    .. list-table::
        :class: colored centered

        * - .. container:: orange-cell

                colored and centered
          - .. container:: green-cell

                text

    .. list-table::
        :class: colored spaced centered

        * - .. container:: orange-cell

                colored, spaced and centered
          - .. container:: green-cell

                text

.. list-table::
    :class: colored

    * - .. container:: orange-cell

            colored
      - .. container:: green-cell

            text

.. list-table::
    :class: colored spaced

    * - .. container:: orange-cell

            colored and spaced
      - .. container:: green-cell

            text

.. list-table::
    :class: colored centered

    * - .. container:: orange-cell

            colored and centered
      - .. container:: green-cell

            text

.. list-table::
    :class: colored spaced centered

    * - .. container:: orange-cell

            colored, spaced and centered
      - .. container:: green-cell

            text
