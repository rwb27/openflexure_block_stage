use <utilities.scad>;
use <compact_nut_seat.scad>;
use <fibre_stage_three_legs.scad>;
include <parameters.scad>;

// nicked from feet.scad in the microscope repo
// TODO: split the feet off the base for ease of assembly

module skew_flat(tilt, shift=false){
    // This transformation skews a plane so it's parallel to the print bed, in
    // the foot (which has been rotated by an angle `tilt`).  Z coordinates are
    // unchanged by this transform; it's a skew **not** a rotation.
    // if shift is true, move things up so that z=0 corresponds to the print
    // bed.  Otherwise, z=0 is below the bottom of the foot (because z=0 is
    // touched by the edge of the foot in the unskewed frame - and the skew will
    // move that side of the model downwards.  It's all because we rotate the
    // model about the corner, rather than the centre...
    l = ss_outer()[1];
    multmatrix([[1,0,0,0],
                [0,1,0,0],
                [0,tan(-tilt),1,shift ? l/2*tan(tilt) : 0],
                [0,0,0,1]]) children();
}
module rx(){
    //handy shorthand for reflecting in X
    reflect([1,0,0]) children();
}

module filleted_bridge(gap, roc_xy=2, roc_xz=2){
    // This can be subtracted from a structure of width gap[0] to form
    // a hole in the bottom of the object with rounded edges.
    // It's used here to smooth the band anchor to avoid damaging the bands.
    w = gap[0];
    b = gap[1];
    h = gap[2];
    x1 = w/2 - roc_xy;
    x2 = w/2 - roc_xz;
    y1 = b/2 + roc_xy;
    difference(){
        translate(-zeroz(gap)/2 -[0,roc_xy,999]) cube(gap + [0,2*roc_xy,roc_xz] + [0,0,999]);
        reflect([0,1,0]) sequential_hull(){
            rx() translate([x1, y1, -999]) cylinder(r=roc_xy, h=d);
            rx() translate([x1, y1, 0]) cylinder(r=roc_xy, h=h+roc_xz);
            rx() translate([x2, b/2, h+roc_xz]) rotate([-90,0,0]) cylinder(r=roc_xz, h=d);
            rx() translate([x2, -2*d, h+roc_xz]) rotate([90,0,0]) cylinder(r=roc_xz ,h=d);
        }
    }
}
// end of stuff nicked from the microscope repo

module base(h=base_height){
    // This isn't beautiful, but lifts the mechanism off the floor and anchors elastic bands
    tilt = -asin(xy_stage_reduction/xy_reduction); // X/Y actuators are not vertical
    xy_a_travel = xy_travel*xy_reduction*cos(tilt); // (Vertical) travel of X/Y actuators
    z_a_travel = z_travel*z_reduction; // Travel of Z actuator
    xy_nut_y = pushstick[1]+xy_lever*xy_reduction*cos(tilt); // centre of actuator columns
    z_nut_y = z_actuator_pivot_y+zflex[1]+z_lever*z_reduction;
    core = column_core_size();
    // Check the base is being produced sufficiently high to accommodate the actuators
    if(base_height < max_actuator_travel + 4) echo(str("WARNING: stage_height is too low, stage travel will be reduced! base height:",base_height," stage height:",stage_height," platform_z:",platform_z));
        
    band = [11, 4, 2.5*2]; // Viton band slot size
    echo("base height is ",h);
    difference(){
        union(){
            // start off by extruding the bottom of the casing to make a bucket
            thick_section(h, z=d) casing();
            thick_section(0.75, z=d) casing(mechanism_void=false);   
            
            //add in properly tilted actuator columns
            each_pushstick() translate([0,xy_nut_y,h]) intersection(){
                mirror([0,0,1]) cylinder(r=999,h=h,$fn=8);
                rotate([tilt,0,0]) screw_seat_outline(999, center=true);
            }
            //include a solid Z actuator column
            translate([0,z_nut_y,0]) screw_seat_outline(h);
                
        }
        // remove the unnecessary thick floor from the box
        translate([0,0,0.75]) thick_section(999) mechanism_void();
        // cut-outs for elastic bands/springs
        each_pushstick() translate([0,xy_nut_y+h*tan(tilt),0]) union(){
            // holes either side of the actuator, for elastic band insertion
            difference(){
                nut_seat_void(99, tilt=tilt, center=true); // space inside the column
                cube([pw+3,999,(h-xy_a_travel)*2],center=true); // elastic band mount
            }
            //elastic band slot (with rounded edges to equalise tension/avoid tearing)
            rotate([tilt,0,0]) skew_flat(tilt) translate([0,0,0]){
                filleted_bridge([2*column_base_radius()+1.5, 3, 2.5], roc_xy=4, roc_xz=3, $fn=16);
            }
        
            // cut the inside wall so the column can
            // move downwards:
            translate([0,-10,h]) cube([7+3,20,2*xy_a_travel-d],center=true);
            
            // cut the outside of the base to remove the excess material
            // from the outer edge of the column (will have been extruded
            // vertically)
            rotate([tilt,0,0]) difference(){
                translate([-99,0,-99]) cube(999);
                screw_seat_outline(999,adjustment=d,center=true);
            }
        }
        translate([0,z_nut_y,0]) union(){
            // holes either side of the actuator, for elastic band insertion
            difference(){
                translate([0,0,-d]) nut_seat_void(99,center=true);
                cube([pw+3,999,(h-z_a_travel)*2],center=true);
            }
            //elastic band slot (with rounded edges to equalise tension/avoid tearing)
            translate([0,0,0]){
                filleted_bridge([2*column_base_radius()+1.5, 3, 2], roc_xy=4, roc_xz=3, $fn=16);
            }
        
            // remember to cut the inside wall so the column can
            // move downwards:
            translate([0,-10,h]) cube([7+3,20,2*z_a_travel-d],center=true);
        }
    }
}

base();