# OpenFlexure Block Stage
A 3D Printable high-precision 3 axis translation stage.

This project is a 3D printable design that enables very fine (sub-micron) mechanical positioning of a small moving stage, with surprisingly good mechanical stability.  It follows on from the [OpenFlexure Microscope](https://github.com/rwb27/openflexure_microscope) which is discussed in a [paper in Review of Scientific Instruments](http://dx.doi.org/10.1063/1.4941068) (open access).

## Kits and License
This project is open-source and is released under the CERN open hardware license.  You can buy a kit of the microscope from [WaterScope](http://www.waterscope.org/).  Currently, only microscope kits are listed, but if you send an email it should be possible to get this stage as a custom order.

## Printing/building it yourself
To build the stage, download the [STL files](./stl/) and print them.  Don't just print everything from the STL folder,
as currently it contains some parts that must be printed multiple times, and other parts
that are redundant.  The readme in that folder should point you in the right direction.

Instructions for this stage are currently work-in-progress.  However, the assembly of the actuators is exactly the same as for the OpenFlexure Microscope, which has [online instructions](http://rwb27.github.io/openflexure_microscope/docubricks/current_master_version.html).  Instead of separate feet, this design has a single baseplate, which is just glued onto the bottom of the main body of the stage.  Once the actuators are assembled as per those instructions, you just need to mount whatever you're going to translate onto the stage using the 8 M3 "self tapping" holes (tapping them with a tap wrench can help get the screw started).  There's a "moving stage" part that makes it a drop-in replacement for the ThorLabs/Newport XYZ fibre alignment stages, if that is of interest.

## Get Involved
It's already useful if you get involved by raising [issues](https://github.com/rwb27/openflexure_block_stage/issues) if there are things that aren't clear, and anyone who might want to help write better instructions would be very welcome.  Ideally it should be in DocuBricks format, but Markdown/Wiki is a lot better than nothing.  Improvements to the code, or even just sharing parameters you used (if you customised it) and how well it worked would be great.  If you've built one, please post a photo and any comments - you could use the wiki, or [raise an issue tagged "build report"](https://github.com/rwb27/openflexure_block_stage/issues/new?labels=build%20report).

