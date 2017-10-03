# OpenFlexure Block Stage STL Files
This folder is for built STL files.  It's possible I should have excluded these from the repo, as they are build products - but it's often handy to have them here.  *Please don't just print this folder* as there is no guarantee that one of each is the right combination of things to print!

To make one stage, you need:
* 1x stage body (``main_body.stl`` - or optionally the one with ``no_fixed_platform`` or ``long_z_travel``)
* 1x base (``base.stl``) - check this matches up with the top part you've chosen (the top of this should match the bottom of the stage - they just glue together).
* 3x ``large_gear.stl`` to actuate the three axes
* 1x moving platform (``moving_platform.stl``) if you would like drop-in compatibility with standard fibre alignment stages.

If you are planning to motorise the stage with 28BYJ-48 stepper motors, you'll also need:
* 3x ``small_gear.stl``

In addition to the printed parts, you also need:
* 3x Viton o-rings
* 3x M3 full nut, preferably brass
* 3x M3 hexagon head bolts, 25mm long
* 3x M3 washer

If you are building a motorised stage, you also need
* 3x 28BYJ-48 stepper motors
* 6x M4x6mm screws (I use button head with a hex socket)

