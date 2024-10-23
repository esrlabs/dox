Test Setups
===========

Available
---------

.. requirement:: SRS_Requirement_TestSetupsSet
    :test_setups: on_target, off_target
    :category: software

.. requirement:: InputRequirement_TestSetupsSet
    :test_setups: manual
    :category: input

.. srs:: SRS_Srs_TestSetupsSet
    :test_setups: on_target, off_target

.. spec:: SWA_Spec_TestSetupsSet
    :test_setups: off_target, on_target

.. unit:: SMD_Unit_TestSetupsSet
    :test_setups: none

.. interface:: SWA_Interface_TestSetupsSet
    :test_setups: off_target

.. interface:: SMD_Interface_TestSetupsSet
    :test_setups: off_target

Default
-------

.. requirement:: SRS_Requirement_TestSetupsDefault
    :category: software

.. requirement:: InputRequirement_TestSetupsDefault
    :category: input

.. srs:: SRS_Srs_TestSetupsDefault

.. spec:: SWA_Spec_TestSetupsDefault

.. spec:: SMD_Spec_TestSetupsDefault

.. unit:: SMD_Unit_TestSetupsDefault

.. mod:: SWA_Mod_TestSetupsDefault

.. interface:: SWA_Interface_TestSetupsDefault

.. interface:: SMD_Interface_TestSetupsDefault

Backward
--------

.. spec:: SWA_Spec_TestSetupsBackward
    :verification_methods: off_target, on_target

.. spec:: SWA_Spec_TestSetupsBackwardBoth
    :verification_methods: off_target, on_target
    :test_setups: manual