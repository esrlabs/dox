.. _backward_compatibility:

Backward Compatibility
======================

.. _backward_compatibility_security:

Security
--------

Security To Cal
+++++++++++++++

It is still possible to use the deprecated attribute ``security`` for specifications.
In case the specification has no ``cal`` attribute set, the value from ``security`` is taken over
with the following mapping:

.. list-table::
   :header-rows: 1

   * - security
     - cal
   * - yes
     - CAL_4
   * - no
     - QM
   * - not_set
     - not_set
   * - *otherwise*
     - *ignore*

| For Dim export, at least Dim 2.0 is required, which supports ``cal`` natively.
| Alternatively, Dim 1.4 can be used with a custom attribute ``cal`` specified in the Dim config:

.. code-block:: yaml

    cal:
      type: single
      default: 'not_set'
      allowed:
        - CAL_1
        - CAL_2
        - CAL_3
        - CAL_4
        - QM
        - not_set

Security Instead of Cal
+++++++++++++++++++++++

*dox_trace* provides a config parameter ``dox_trace_security_backward``. If set to *True*, the
attribute ``security`` is shown instead of ``cal`` and ``Upstream Security`` instead of
``Upstream Cal``.

In case the specification has no ``security`` attribute set, the value from ``cal`` is taken over
with the following mapping:

.. list-table::
   :header-rows: 1

   * - cal
     - security
   * - CAL_1
     - yes
   * - CAL_2
     - yes
   * - CAL_3
     - yes
   * - CAL_4
     - yes
   * - QM
     - no
   * - not_set
     - not_set
   * - *otherwise*
     - *ignore*

| For Dim export, Dim 1.4 or below is required, which supports ``security`` natively.
| Alternatively, Dim 2.0 and above can be used with a custom attribute ``security`` specified in the
  Dim config:

.. code-block:: yaml

    security:
      type: single
      default: not_set
      allowed:
        - yes
        - no
        - not_set

.. _backward_compatibility_test_setups:

Test Setups
-----------

Test Setups To Verification Methods
+++++++++++++++++++++++++++++++++++

It is still possible to use the deprecated attribute ``test_setups`` for specifications.
In case the specification has no ``verification_methods`` attribute set, the value from
``test_setups`` is taken over.

For Dim export, at least Dim 2.0 is required, which supports ``verification_methods`` natively.

Test Setups Instead of Verification Methods
+++++++++++++++++++++++++++++++++++++++++++

*dox_trace* provides a config parameter ``dox_trace_test_setups_backward``. If set to *True*, the
attribute ``test_setup`` is shown instead of ``verification_methods``.

In case the specification has no ``test_setup`` attribute set, the value from
``verification_methods`` is taken over.

For Dim export, Dim 1.4 or below is required, which supports ``test_setups`` natively.
