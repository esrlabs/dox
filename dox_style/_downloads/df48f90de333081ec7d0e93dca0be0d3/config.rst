Configuration
=============

This extension **pre-configures** the Sphinx workspace with default settings and provides
common **styles** for HTML and LaTeX output. It significantly reduces copy/paste between different
Sphinx configuration files and harmonizes the look and feel of documentations.

The following default configuration can be overwritten (if really needed!) by adding a file
*extend_conf.py* next to *conf.py*. This file must provide a function
*def extend_conf(config: dict)*. The loading order of the configurations is *conf.py*, then
this extension and finally *extend_conf.py*.

Common
------

- Adds a check for duplicate labels, which does not work reliable in parallel builds, see also
  https://github.com/sphinx-doc/sphinx/issues/4459
- Enables PlantUML
- Makes glossary case insensitive

HTML
----

- Sets `Read the Docs <https://docs.readthedocs.io/en/stable/index.html>`_ as theme and changes
  some default settings
- Makes the **navigation bar** in HTML output a little bit wider
- Allows up to six **navigation levels** in the navigation bar
- Makes navigation bar **sticky**
- **Wraps** text in tables by default
- Adds a small superscripted icon after **external links**
- Hides **previous/next** page buttons
- Removes the **Generated with Sphinx** text from the footer
- Adds the build date to the page footer
- Adds the build type (unofficial/offical) to the page footer
- Adds an optional :ref:`sphinx_footer_string` to the page footer
- Adds :ref:`sphinx_data_classification`
- Adds :ref:`sphinx_document_status`
- Adds :ref:`sphinx_text_colors`
- Adds :ref:`sphinx_table_colors`
- Adds **raw-html** role
- Removes the **integrity-check** for script files. |br|
  This prevents problems with *cross-origin resource sharing* e.g. when trying to load jQuery.
- Replaces style for **download** role (e.g. download :download:`this page <config.rst>`)

.. toctree::
   :maxdepth: 1
   :hidden:

   config/data_classification
   config/document_status
   config/text_colors
   config/table_colors
   config/footer_string

LaTeX
-----

- Configures LaTeX exporter to handle special **unicode characters**
