/*

An adapter to fit the OpenFlexure Microscope optics module on the
fibre alignment stage

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <utilities.scad>;
use <dovetail.scad>;
include <../parameters.scad>;

//beam_height = platform_z + 3 + 10 + 6; //for picamera lens optics
beam_height_from_platform = 12.7;
beam_height = platform_z + 12.7; //for compatibility with standard stuff
objective_clip_w = 10;
objective_clip_y = 6;
clip_outer_w = objective_clip_w + 4;

module optics_to_platform(){
    h=25;
    clip_l = 5;
    keel = [3-0.3,1,h];
    translate([0,beam_height_from_platform-clip_l,0]) mirror([0,1,0]) dovetail_clip([10+2*1,clip_l,h],solid_bottom=0.5,slope_front=3,t=1);
    translate([-16,0,0]) cube([32,3+d,h]);
    translate([-keel[0]/2,-keel[1],0]) cube(keel+[0,d,0]);
    //supports for during the print (snap off later)
    reflect([1,0,0]) translate([-16,0,0]) cube([8,10,0.5]);
    reflect([1,0,0]) translate([-16,0,0]) hull(){
       cube([1,8,0.5]);
       cube([1,1,8]);
    }
}

module plate_with_keel(t=3, l=12){
    // A plate that sits on top of the fixed/moving platforms of the stage.
    keel = [3-0.3,1,l];
    union(){
        translate([-16,0,0]) cube([32,t+d,l]);
        translate([-keel[0]/2,-keel[1],0]) cube(keel+[0,d,0]);
    }
}

module rms_to_platform(){
    l=15;
    rms_r = 25.4*0.8/2-0.25; //see the openflexure microscope module
    pitch=0.7056;
    hole_r = rms_r - 0.44;
    outer_r = hole_r + 1.2;
    
    // First, the bit that fixes to the stage
    plate_with_keel(l=l);
    
    // Then, a place to put the thread
    difference(){
        hull(){
            translate([-outer_r,d,0]) cube([2*outer_r,d,l]);
            cylinder(r=outer_r, h=l);
        }
        cylinder(r=hole_r, h=999, center=true);
    }
    inner_thread(radius=rms_r,threads_per_mm=pitch,thread_base_width = 0.60,thread_length=5);
}
rms_to_platform();

module disc_to_platform(){
    h=12;
    id=25.4;
    bh=12.7;//beam height
    ot=4;//optic thickness
    keel = [3-0.3,1,h];
    difference(){
        union(){
            translate([-16,0,0]) cube([32,3+d,h]);
            translate([-keel[0]/2,-keel[1],0]) cube(keel+[0,d,0]);
            difference(){
                hull(){
                    translate([0,bh,0]) cylinder(d=id+3,h=h,$fn=64);
                    translate([-5,bh+id/2,0]) cube([10,10,h]);
                }
                //ground
                translate([0,-999,0]) cube(999*2, center=true);
                
            }
        }
        
        //optic
        difference(){
            translate([0,bh,1]) cylinder(d=id, h=999, $fn=64);
            translate([-999,bh-id/2,1+ot]) rotate([75,0,0]) cube(999*2);
        }
        translate([0,bh,-1]) cylinder(d=id-2, h=ot+1, $fn=64);
        
        //bolt
        translate([0,bh+id/2+5,h/2]) rotate(90) pinch_y(4,t=2, nut_l=999,screw_l=10,extra_height=0,gap=[30,4,999]);
    }
}
//disc_to_platform();

module slide_holder(){
    h = beam_height - shelf_z2 - stage[2] + 5;
    w = 20;
    so = fixed_platform_standoff;
    difference(){
        union(){
            translate([-w/2,-so+2,0]) cube([w,4,h]);
            translate([-w/2,-so+2,0]) cube([w,so-2 + 2 + 4,4]);
        }
        reflect([1,0,0]) hull() reflect([0,1,0]) translate([5*sqrt(2),2,1]) cylinder(d=3.5,h=20,$fn=16, center=true);
        reflect([1,0,0]) hull() reflect([0,1,0]) translate([5*sqrt(2),2,1]) cylinder(r=3.2,h=10,$fn=16);
        translate([0,0,beam_height - shelf_z2 - stage[2]]) rotate([90,0,0]) cylinder(d=3.2,h=999,center=true,$fn=16);
    }
}
//slide_holder();

module inch_disc_holder(){
    h = beam_height - shelf_z2 - stage[2] + 5;
    w = 20;
    so = fixed_platform_standoff;
    id=25.4;
    difference(){
        union(){
            translate([0,-so+2,beam_height - shelf_z2 - stage[2]]) hull(){
                rotate([-90,0,0]) cylinder(d=id+3,h=4,$fn=32);
            }
            translate([-w/2,-so+2,0]) cube([w,4,h]);
            translate([-w/2,-so+2,0]) cube([w,so-2 + 2 + 4,4]);
        }
        reflect([1,0,0]) hull() reflect([0,1,0]) translate([5*sqrt(2),2,1]) cylinder(d=3.5,h=20,$fn=16, center=true);
        translate([0,-so+3,beam_height - shelf_z2 - stage[2]]) rotate([-90,0,0]) cylinder(d=id,h=999,$fn=64);
        translate([0,-so+3,beam_height - shelf_z2 - stage[2]]) rotate([-90,0,0]) cylinder(d=id-2,h=999,center=true,$fn=64);
    }
}
//inch_disc_holder();
//difference(){
//    cylinder(d=23,h=8);
//    cylinder(d=10,h=999,center=true);
//}
//optics_to_platform();
