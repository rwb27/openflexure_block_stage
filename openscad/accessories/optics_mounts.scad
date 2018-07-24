/*

An adapter to fit the OpenFlexure Microscope optics module on the
fibre alignment stage

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/
use <utilities.scad>;
use <dovetail.scad>;
use <thorlabs_threads.scad>;
include <../parameters.scad>;

module plate_with_keel(t=3, l=12, in_situ=false){
    // A plate that sits on top of the fixed/moving platforms of the stage.
    // if in_situ is false, the plate is vertical, such that the Z axis is the
    // optical axis.  If in_situ is true, the keel starts at x=y=0 and the plate
    // sits on z=stage_height
    keel = [3-0.3,l,1];
    translate(in_situ?[0,0,stage_height]:[0,-stage_to_beam_height,l]) 
    rotate([in_situ?0:-90,0,0]) union(){
        translate([-16,0,0]) cube([32,l,t]);
        translate([-keel[0]/2,0,-keel[2]]) cube(keel+[0,0,d]);
    }
}
module plate_with_keel_base(t=3, l=12, w=25, in_situ=false){
    // If you're mounting to a plate_with_keel, you can convex hull to
    // this part in order to join to it nicely.
    // NB if w>28 you will struggle to attach the plate to the stage.
    if(w>28) echo("WARNING: You've got to keep the width of stuff < 28mm to attach to the base");
    keel = [3-0.3,l,1];
    translate(in_situ?[0,0,stage_height]:[0,-stage_to_beam_height,l]) 
    rotate([in_situ?0:-90,0,0]){
        translate([-w/2,0,t-d]) cube([w,l,d]);
    }
}

rms_mount_hole_spacing = 18;
module each_rms_mounting_hole(){
    for(a=[0,90,180,270]) rotate(a) translate([1,1,0]*rms_mount_hole_spacing/2) children();
}    
rms_mount_l = 25;
module rms_to_platform(mounting_holes=false, l=rms_mount_l){
    // A mount for an RMS objective that screws to the fixed/moving plate.
    // l is the length of the mount
    rms_r = 25.4*0.8/2-0.25; //see the openflexure microscope module
    pitch=0.7056;
    hole_r = rms_r + 0.44;
    outer_r = hole_r + 1.2;
    
    difference(){
        union(){
            // First, the bit that fixes to the stage
            plate_with_keel(l=l);
            hull(){
                // Then, a place to put the thread 
                cylinder(r=outer_r, h=l);
                // Join it to the bottom of the mount
                plate_with_keel_base(l=l, w=outer_r*2);
                // And make sure there are places to bolt to (if needed)
                if(mounting_holes) each_rms_mounting_hole() cylinder(r=3, h=l);
            }
        }
        cylinder(r=hole_r, h=999, center=true);
        if(mounting_holes) each_rms_mounting_hole() translate([0,0,-1]) cylinder(d=3, h=999, $fn=8);
    }
    translate([0,0,l-5]) inner_thread(radius=rms_r,threads_per_mm=pitch,thread_base_width = 0.60,thread_length=5);
}
rms_to_platform(l=25,mounting_holes=true);

module microscope_to_rms_mount_holes(top_z){
    // Holes to bolt the microscope module to the RMS mount above
    for(a=[0,45]) rotate(a) each_rms_mounting_hole(){
        translate([0,0,top_z-3-d]) cylinder(d=3.3, h=999, $fn=8);
        hull(){
            translate([0,0,top_z-3-5-d]) cylinder(r=3, h=d+5, $fn=16);
            translate([2.5,2.5,top_z-3-5-d-10]) cylinder(r=3, h=d+5, $fn=16);
        }
    }
}

module openflexure_microscope_module(rms_mount_l=rms_mount_l){
    // a cut down optics module that bolts to the RMS mount above
    // this is useful for observing the motion of the stage.
    top_z = 65-35-rms_mount_l;
    outer_r = rms_mount_hole_spacing/sqrt(2)+3;
    inner_r = 18; // this should be small enough to fit inside the RMS thread but
                  // big enough to clear the inner lens mount.
    difference(){
        // Start with an optics module:
        import("optics_module_rms_f50d13_nodovetail.stl");
        
        // Chop off the built-in RMS objective mount
        translate([0,0,top_z]) difference(){
            cylinder(r=999,h=999,$fn=3);
            cylinder(d=inner_r,h=999,center=true);
        }
        
        microscope_to_rms_mount_holes(top_z);
    }
    difference(){
        // Add a mounting flange to the top
        hull(){
            translate([0,0,top_z-3]) cylinder(r=outer_r, h=3);
            translate([0,0,top_z-3-10]) cylinder(r=outer_r-10, h=3);
        }
        cylinder(d=inner_r,h=999,center=true);
        microscope_to_rms_mount_holes(top_z);
        for(a=[0,45]) rotate(a+180) translate([-999,12.4,-999]) cube(9999);
    }
    
}
//openflexure_microscope_module(25);

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
