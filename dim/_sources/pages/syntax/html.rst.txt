.. _html_support:

HTML Support
============

Dim is based on YAML, which initially means that requirements are described textually. When
exporting to RST, Dim interprets text between ``<html>`` and ``</html>`` as HTML.

External files (e.g. referenced in ``<img>``) need to be added to the *enclosed* attribute
so that they are exported/copied correctly.

The following sections show some examples how to specify HTML elements.

Text Formatting
---------------

.. code-block:: yaml

    SRS_Feature_A1:
      text: <html><b>Bold</b> and <i>italic</i> text with an extra<br>newline</html>.

Images
------

.. code-block:: yaml

    enclosed:
      - images/overview.png

    SRS_Feature_A2:
      text: Look at this:<html><br><img src="images/overview.png" width="50%"/></html>

Tables
------

.. code-block:: yaml

    SRS_Feature_A3:
      text: <html><table>
              <tr>
                <th>Voltage</th>
                <th>Amp</th>
              </tr>
              <tr>
                <td>12 V</td>
                <td>100 mA</td>
              </tr>
            </table></html>
