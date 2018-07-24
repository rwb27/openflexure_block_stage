/*

An adapter to fit an LED behind a vertical microscope slide

TODO: locate the SCAD source file for the vertical slide clips!

(c) 2017 Richard Bowman - released under CERN Open Hardware License

*/

use <../utilities.scad>;
include <../parameters.scad>;

hole_sep = 40;
hole_d = 3.5;
beam_h = stage_to_beam_height;
d = 0.05;

w = hole_sep + hole_d + 4;
t = hole_d+4;
$fn=16;

difference(){
    union(){
        translate([-w/2,0,0]) cube([w,t,2.5]); //mounts to two holes
        translate([-10/2,0,0]) cube([10,t,beam_h+5]);
    }
    
    reflect([1,0,0]) translate([-hole_sep/2,t/2,-1]) cylinder(d=hole_d,h=999);
    translate([0,-99,beam_h]) rotate([-90,0,0]) cylinder(d=3.3, h=999);

}