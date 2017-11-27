/*

OpenFlexure Fibre Stage

This project aims to be a high-performance flexure stage, with
short (~2mm) travel and very good accuracy and stability.  It
differs from the microscope by having shorter travel and more
mechanical reduction.  It also has all three axes combined on
one moving stage, rather than separating XY and Z.

*/
use <utilities.scad>;
use <compact_nut_seat.scad>;
include <parameters.scad>;


module xy_table(){
    // XY table structure (anchors to Z stage)
    // This includes the legs and flexures for the XYZ stage and the
    // bottom part to which the XY actuators connect.
    reflect([1,0,0]) reflect([0,1,0]){
        // legs
        translate([stage[0], stage[1], 0]/2 + [1,1,0]*zflex[1]) cube([1,1,0]*zflex[0] + [0,0,shelf_z2 + stage[2] - 2]);
        
        for(z=[0,shelf_z1, shelf_z2]){
            // bridges between legs
            translate([stage[0]/2+zflex[1],-d,z]){
                cube([zflex[0], zflex[1]+stage[1]/2+2*d, zflex[2]]);
                cube([zflex[0], stage[1]/2+d, stage[2]]);
            }
            //shelves between bridges
            translate([-d,-d,z+2*dz]) cube(stage/2+[0,0,stage[2]/2-2*dz]);
            translate([-d, stage[1]/2-zflex[0], z+dz]) cube([stage[0]/2+zflex[1]+2*d, zflex[0], zflex[2]]);
        }
        translate([-d,-d,0]) cube(stage/2); //bottom sits on z=0
    }
}

module x_flexure(){
    // A flexure that bends along the Z direction, for motion in X
    roc = (xflex[0]-xflex_t)/2;
    difference(){
        translate([0,0,xflex[2]/2]) cube(xflex + [0,2*d,0], center=true);
        
        reflect([1,0,0]) hull() reflect([0,1,0]) reflect([0,0,1]){
            translate(xflex/2 - [0,roc,0]) cylinder(r=roc+d, h=999,$fn=16);
        }
    }
}
module xz_flexure(){
    // Two flexures to allow XZ motion of a beam extending along the Y axis
    w = pw;
    h = pushstick[2];
    // Start with an X flexure
    translate([0,xflex[1]/2,0]) x_flexure();
    sequential_hull(){
        translate([0,xflex[1]+w/8,h/2]) cube([w,w/4,h],center=true);
        translate([-w/2,xflex[1]+w/2,0]) cube([w,d,zflex[2]]);
        translate([-w/2,xflex[1]+w/2+zflex[1],0]) cube([w,d,zflex[2]]);
    }
}
module pushstick(){
    // A beam with 2-axis flexures at either end, to constrain 
    // position in 1D
    w = pw;
    h = pushstick[2];
    l = pushstick[1];
    flex_l = xflex[1]+w/2+zflex[1];
    difference(){
        union(){
            repeat([0,l-flex_l,0], 2) xz_flexure();
            translate([-w/2,flex_l,0]) cube([w,l-2*flex_l+d,h]);
        }
        
    }
}
module each_pushstick(){
    // Transformation that creates two pushsticks at 45 degrees
    reflect([1,0,0]) rotate(45) translate([0,pw/2,0]) children();
}

module mechanism_void(){
    //cut-out in the centre of the casing for the mechanism
    difference(){
        sequential_hull(){
            union(){
                cube(stage + [2,2,0]*(xy_bottom_travel + zflex[1] + zflex[0] + 0.5), center=true);
                translate([0,z_stage_base_y-zflex[1]-z_lever+d,0]) 
                        cube([stage[0],2*d,stage[2]*2], center=true);
            }
            translate([0,0,shelf_z1]) union(){
                cube(stage + [2,2,0]*(zflex[1] + zflex[0] + 1.0), center=true); 
                translate([0,-stage[1]/2-zflex[1]-z_lever+d,0]) 
                        cube([stage[0],2*d,d], center=true);
            }
            translate([0,0,shelf_z2]) 
                    cube(stage + [2,2,0]*(zflex[1] + zflex[0] + 1.0 + xy_travel)
                         + [0,0,stage[2]+z_travel*2+6], center=true); 
        }
        
        // take a chunk out to allow for Z actuator reinforcement
       translate([0,z_actuator_pivot_y, 0]) mirror([0,1,0]) hull(){
            w = 2*(z_actuator_pivot_y - pushstick[0]/sqrt(2) - xy_bottom_travel*sqrt(2)) - 1;
            //w = z_actuator_pivot_w;
            translate([-w/2,0,-d]) cube([w, wall_t, shelf_z2]);
            translate([-w/2 + 8,0,-d]) cube([w-8*2, wall_t+6, shelf_z2]);
        }
    }
}
module inter_shelf_spaghetti_slots(){
    // cut outs to clear "spaghetti" from inside of stage
    translate([0,0,shelf_z2-2]) cube([999,10,3],center=true);
    translate([0,0,shelf_z2-2]) cube([10,999,3],center=true);
}

module casing_outline(cubic=true){
    // Once the mechanism void is subtracted, this makes a minimal wall around the structure.
    // NB you need to chop off the top and bottom too.
    if(cubic){
        s = xy_bottom_travel + zflex[1] + zflex[0] + 0.5 + wall_t;
        translate([-stage[0]/2-s, z_anchor_bottom_y-wall_t, 0])
                cube(stage + [2*s,s + (-z_anchor_bottom_y-stage[1]/2) + wall_t,shelf_z2]);
    }else{
        minkowski(){
            hull() mechanism_void();
            cylinder(r=wall_t, h=d, center=true, $fn=8);
        }
    }
}
module casing_outline_top(){
    // 2D object for the top of the casing
    projection(cut=true) translate([0,0,-casing_top + d]) difference(){
        casing_outline();
        mechanism_void();
    }
}

module fixed_platform(){
    // fixed platform to mount objectives, etc.
    so = fixed_platform_standoff;
    difference(){
        hull(){
            //"shelf" part overhanging the edge
            rotate(-135) translate([0,so,platform_z]) mirror([0,0,1]){
                translate([-fixed_platform[0]/2,0,0]) cube(fixed_platform);
                translate([-d,0,0]) cube([2*d, d, fixed_platform[1]+fixed_platform[2]]);
            }
            //"bridge" part 
            translate([0,0,casing_top-d]) 
                    linear_extrude(platform_z-casing_top+d)
                    intersection(){
                        casing_outline_top();
                        rotate(-135) translate([-999,so]) square(999*2);
                    }
        }
        mechanism_void();
        //alignment groove (compatible with standard objective mounts)
        translate([0,0,platform_z]) rotate(-135) cube([3,999,1.7*2],center=true);
        //mounting holes (compatible with standard mounts)
        difference(){
            // NB we leave the bottom closed if it's over the void
            // to avoid messing up the bridge
            rotate(-135) translate([0,so+5,platform_z]) 
                repeat([40,0,0],2,center=true)
                repeat([0,10,0],10) cylinder(r=3/2*0.9,h=20,center=true);
            translate([0,0,0.5]) mechanism_void();
        }
        inter_shelf_spaghetti_slots(); //access ports for print clean-up
    }
}
//fixed_platform();

module moving_platform(){
    // extension to the stage to make it bigger and match fixed platform
    // (not finished)
    stage_top = shelf_z2 + stage[2];
    h = platform_z - stage_top;
    so = fixed_platform_standoff;
    start_y = -so+xy_travel*sqrt(2);
    p = fixed_platform;
    dr = h - p[2]; //amount to move in from top to bottom, for the overhanging sides.
    echo("Platform height is", platform_z);
    difference(){
        hull(){
            //top of the platform
            rotate(45) translate([-p[0]/2,start_y,platform_z - p[2]]) cube(p);
            //bottom of the platform (with 45 degree overhang)
            rotate(45) translate([-p[0]/2+dr,start_y,stage_top]) cube(p-[2,1,0]*dr);
        }
        //alignment groove (compatible with standard objective mounts)
        translate([0,0,platform_z]) rotate(-135) cube([3,999,1.7*2],center=true);
        //mounting holes (compatible with standard mounts)
        // NB we leave the bottom closed if it's over the void
        // to avoid messing up the bridge
        rotate(45) translate([0,start_y+5,platform_z]) 
            repeat([40,0,0],2,center=true)
            repeat([0,10,0],10) cylinder(r=3/2*0.9,h=20,center=true);
        
        //mounting holes in the moving stage
        translate([0,0,stage_top + 1])
            repeat([10,0,0],4,center=true)
            repeat([0,10,0],2,center=true){
                cylinder(d=3*1.15,h=999, center=true);
                cylinder(d=2*3*1.15,h=999);
        }
    }
            
        
}
//moving_platform();

module casing(mechanism_void=true){
    // This is the cuboidal casing and actuator housings.  It's the
    // main structural component.
    difference(){
        union(){
            //minimal wall around the mechanism (will be hollowed out later)
            casing_outline();
            
            //NB the arguments here are repeated below
            //covers and screw seats for the XY actuators
            each_pushstick() translate([0,pushstick[1]-zflex[1],0]) actuator_shroud_shell(shelf_z1, pw, xy_actuator_pivot_w, xy_lever*xy_reduction, tilted=true, extend_back=pushstick[1]-10);
            //cover and screw seat for the Z actuator
            translate([0,z_actuator_pivot_y,0]) actuator_shroud_shell(z_pushstick_z+pushstick[2]+1, z_actuator_pivot_w, pw, z_lever*z_reduction, tilted=false, extend_back=wall_t);
            
            //Mounting bolts
            for(bolt_pos=mounting_bolts){
                hull(){
                    translate(bolt_pos) cylinder(r=10,h=8);
                    cylinder(r=20, h=18);
                }
            }
        }
        // limit the wall in Z
        translate([0,0,shelf_z2 + stage[2] - z_travel]) cylinder(r=999,h=999,$fn=8);
        translate([0,0,-99]) cylinder(r=999,h=99,$fn=8);
        // mounting bolt holes        
        for(bolt_pos=mounting_bolts) translate(bolt_pos+[0,0,3]){
            sequential_hull(){
                translate([0,0,0]) cylinder(r=6,h=d);
                translate([0,0,8]) cylinder(r=6,h=d);
                translate([0,0,250]+bolt_pos) cylinder(r=6,h=d);
            }
            cylinder(r=6/2*1.1,h=999,center=true);
        }
        
        // make it a wall not a block - clearance for the mechanism
        if(mechanism_void){
            mechanism_void();
        
            //inside of covers and screw seats for the XY actuators
            each_pushstick() translate([0,pushstick[1]-zflex[1],0]) actuator_shroud_core(shelf_z1, pw, xy_actuator_pivot_w, xy_lever*xy_reduction, tilted=true, extend_back=pushstick[1]-10, anchor=true);
            //cover and screw seat for the Z actuator
            translate([0,z_actuator_pivot_y,0]) actuator_shroud_core(z_pushstick_z+pushstick[2]+1, z_actuator_pivot_w, pw, z_lever*z_reduction, tilted=false, extend_back=flex_a*(z_pushstick_z+pushstick[2]+1)+0.5, anchor=true);
            //clearance for the Z pushstick
            translate([-pw/2-1.5,0,z_pushstick_z-3]) cube([pw+3,z_actuator_pivot_y+d, pushstick[2]+3+3]);
        }
        
        inter_shelf_spaghetti_slots(); //access ports to clean up poor bridging inside
    }
}

module slide_support(){
    // This piece screws diagonally onto the moving part to 
    // support a vertical microscope slide for tracking experiments
    sep = sqrt(2)*10;
    difference(){
        hull(){
            cube([sep+8, 8, 17]);
        }
        translate([4,4,2]) repeat([sep,0,0],2){
            cylinder(r=3/2*1.1, h=999,center=true);
            cylinder(r=3,h=999);
        }
    }
}

module thick_section(h, z=0, center=false){
    linear_extrude(h, center=center) projection(cut=true){
        translate([0,0,-z]) children();
    }
} 

difference(){
    //main_body();
    //rotate([0,90,0]) cylinder(r=999,h=999,$fn=8);
}

//base();