/*

An adapter to fit an 11mm diameter laser diode module to the stage

(c) 2018 Richard Bowman - released under CERN Open Hardware License

*/

use <utilities.scad>;
use <cylinder_clamp.scad>;

hole_sep = 40;
hole_d = 3.5;
beam_h = 12.7;
d = 0.05;

w = hole_sep + hole_d + 4;
t = hole_d+4+10;
$fn=16;

rotate([-90,0,0]) translate([0,-t,0]) difference(){
    union(){
        translate([-w/2,0,0]) cube([w,t,2.5]); //mounts to two holes
        //translate([-10/2,0,0]) cube([15,t,]);
        translate([0,t/2,12.5]) rotate([90,0,0]) 
            cylinder_clamp(inner_r=11/2+0.5,
                           clamp_h=t,
                           clamp_t=3,
                           flat_t=10-11/2,
                           flat_width=15,
                           mounting_bolt=0);
    }
    
    reflect([1,0,0]) repeat([0,10,0],2) translate([-hole_sep/2,hole_d/2+2,3]){
        cylinder(d=hole_d,h=999, center=true);
        cylinder(d=4,h=999);
    }
    translate([0,-99,beam_h]) rotate([-90,0,0]) cylinder(d=3.3, h=999);

}