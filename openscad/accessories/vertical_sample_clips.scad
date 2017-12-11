/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Optics unit                             *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <utilities.scad>;

//this is for mini culture plates, 39mm outer diameter and 12.4mm high
sample=[0,19/2,12.4-1.5-9]; //position of clamping point relative to bolt

$fn=32;
d = 0.05;

module sample_clip(sample,t=2.5,w=6,roc=-1,slope=30){
    roc = roc>0 ? roc : sample[2]/2 + sample[1]*sin(slope) - t/2; //radius of curvature
    a = sqrt(pow(sample[1], 2) + pow(sample[2] - roc - t/2, 2));
      //a is the distance from the contact-point cylinder to the 
      //centre of the curved part
    angle = acos( (roc + t/2) / a ) + atan((sample[2] - roc - t/2)/sample[1]); //angle through which we must rotate the join between
    //curved part and straight part
    echo("angle set to:",angle);
    /*angle = 75; //angle of straight part to the vertical
    roc =*/ 
    difference(){
        union(){
            //anchor to stage
            //cylinder(r=w/2,h=t);
            
            translate([0,0,roc+t]) rotate([0,90,0]) difference(){
                cylinder(r=roc+t,h=w,center=true);
                cylinder(r=roc,h=999,center=true);
                translate([0,0,-99]) rotate(0) cube([999,999,999]);
                translate([0,0,-99]) rotate(angle) cube([999,999,999]);
            }
            sequential_hull(){
                translate([0,0,roc+t]) rotate([0,90,0]) rotate(angle) translate([0,roc+t/2,0]) cylinder(r=t/2,h=w,center=true);
                translate([0,sample[1],sample[2]+t/2]) rotate([0,90,0]) cylinder(r=t/2,h=w,center=true);
                translate([0,sample[1]+t,sample[2]+t]) rotate([0,90,0]) cylinder(r=t/2,h=w,center=true);
            }
            
        }
        //cylinder(r=3/2*1.2,h=999,center=true,$fn=16);
    }
}


// we want to clamp the centre of a microscope slide, 12.5mm above the ground
// there will be a spacer 
clip_l = 15;
beam_h = 12.5;
bottom = 2.5;
w = 7;

{
    translate([0,0,clip_l + beam_h]) rotate([-90,0,0]) 
                            sample_clip([0,clip_l,2], w=w, roc=6);
    difference(){
        translate([-w/2,0,bottom]) cube([w, 2.5, beam_h + clip_l + d - bottom]);
        translate([0,2.5+5-1,beam_h]) rotate([0,90,0]) cylinder(h=999, r=5, center=true);
    }
    difference(){
        translate([-w/2,-w,bottom]) cube([w, w+d, 2.5]);
        translate([0,-w/2,-1]) cylinder(r=3/2*1.2, h=999, $fn=16);
    }
}
/*
translate([10,0,0]) sample_clip([0,20,0]);
translate([20,0,0]) sample_clip([0,20,10]);
translate([30,0,0]) sample_clip([0,10,3]);
translate([40,0,0]) sample_clip([0,10,15]);
*/