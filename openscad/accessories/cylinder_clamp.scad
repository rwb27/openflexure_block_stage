use <../utilities.scad>;
d=0.05;

//for 1 inch/25mm post clamp, an inner radius of 12.8 is good.
	
module cylinder_clamp(
	inner_r=12.8, //radius of the cylinder being clamped (ish!)
	clamp_h=11, //thicknedess of the clamp along the cylinder axis
	clamp_t=4, //thickness of the clamp radially
	flat_t=8, //how thick the bottom of the clamp is (often need to allow for the mounting bolt head here)
	flat_width=15, //width of the flat base
	mounting_bolt=4, //nominal size of mounting bolt (default is 4 for M4, 0 to disable)
	nut_trap=false,
	bevel_top=0.5, //size of 45 degree bevel on top surface
	bevel_bottom=0.8 //size of 45 degree bevel on bottom of hole
	){
	assign(
		post_r = inner_r, //poor initial choice of name!
		bolt_flat_w=10, //width of the region where the bolt is
		gap_w=3 //size of the gap that is squeezed by the bolt
	)
	difference(){
		hull(){
			cylinder(h=clamp_h,r=post_r+clamp_t,center=true,$fn=48);
			translate([0,-post_r-flat_t/2,0]) cube([flat_width,flat_t,clamp_h],center=true);
			translate([0,post_r+bolt_flat_w/2,0]) cube([12,bolt_flat_w,clamp_h],center=true);
		}
	
		cylinder(h=9999,r=post_r,center=true,$fn=48); //cylinder being clamped
		//bevels, top and bottom
		translate([0,0,-clamp_h/2]) cylinder(r1=post_r+3*bevel_bottom,r2=post_r-bevel_bottom,h=4*bevel_bottom,center=true);
		translate([0,0,clamp_h/2]) cylinder(r2=post_r+3*bevel_top,r1=post_r-bevel_top,h=4*bevel_top,center=true);
		//gap (squeezed by bolt)
		translate([0,999,0]) cube([gap_w,999*2,999],center=true); //gap
	
		//clamping bolt
		translate([gap_w/2+2,post_r+bolt_flat_w/2,0]) rotate([0,0,-90]) nut_y(4,h=999,shaft=true);
		translate([-gap_w/2-2,post_r+bolt_flat_w/2,0]) rotate([0,0,90]) cylinder_with_45deg_top(r=4,h=999,$fn=16); //counterbore for nut head
	
		if(mounting_bolt > 0){
			//mounting bolt
			translate([0,-post_r-4.5,0]) rotate([-90,0,0]){
				intersection(){
					rotate([90,0,0])
						if(nut_trap){
							nut_y(mounting_bolt,fudge=1.15,shaft=true,h=999);
						}else{
							screw_y(mounting_bolt,fudge=1.07,shaft=true,h=999);
						}
					cube([inner_r*2,inner_r*2,clamp_h*2],center=true);
				}
			}
		}
		//in the case of thick clamps with thin flats, this keeps the bottom flat
		translate([0,-inner_r-flat_t-999,0]) cube([9999,999*2,9999],center=true);
	}
}

module cylinder_clamp_v(
	inner_r=12.8, //radius of the cylinder being clamped (ish!)
	clamp_h=10, //width of the clamp along the cylinder (y) axis
	clamp_t=4, //thickness of the clamp radially
	flat_t=8, //how thick the bottom of the clamp is (often need to allow for the mounting bolt head here)
	flat_width=15, //width of the flat base
	mounting_bolt=4, //nominal size of mounting bolt (default is 4 for M4, 0 to disable)
	bevel=0.5 //put a 45 degree bevel on the edges of the hole
	){
	assign(
		post_r = inner_r, //poor initial choice of name!
		bolt_flat_w=11, //width of the region where the bolt is
		gap_w=2*inner_r*sin(45/2),//sin(acos(1-(9/2-4/2*1.22)/inner_r))*inner_r //size of the gap that is squeezed by the bolt
		bolt_z = inner_r+4/2*1.22+d //position of bolt (so bolt just clears the cylinder we're clamping
	)assign( //the second assign statement allows us to use gap_w
		bolt_span=gap_w+4+d//max(2*inner_r*sin(acos(1-(9/2-4/2*1.22)/inner_r)), gap_w+4)
	)
	difference(){
		hull(){
			rotate([90,0,0]) cylinder(h=clamp_h,r=inner_r+clamp_t,center=true,$fn=48);
			translate([0,0,-inner_r-flat_t/2]) cube([flat_width,clamp_h,flat_t],center=true);
			translate([0,0,bolt_z]) cube([gap_w+9,clamp_h,bolt_flat_w],center=true);
		}
	
		cylinder_with_45deg_top(h=9999,r=post_r,center=true,$fn=48); //cylinder being clamped
		reflect([0,1,0]) translate([0,clamp_h/2,0]) rotate([90,0,0]) cylinder(r1=post_r+3*bevel,r2=post_r-bevel,h=4*bevel,center=true); //bevel
		translate([0,0,999]) cube([gap_w,999,999*2],center=true); //gap
	
		//clamping bolt
		translate([bolt_span/2,0,bolt_z]) rotate([0,0,-90]) nut_y(4,h=999,shaft=true);
		translate([-bolt_span/2,0,bolt_z]) rotate([0,0,90]) cylinder_with_45deg_top(r=4,h=999,$fn=16); //counterbore for nut head
	
		if(mounting_bolt > 0){
			//mounting bolt
			translate([0,0,-post_r-4.5]){
				cylinder(r=mounting_bolt*1.1,h=post_r,$fn=16);
				cylinder(r=mounting_bolt/2*1.22,h=flat_t*2,center=true,$fn=16);
			}
		}
		translate([0,0,-inner_r-flat_t-999]) cube([9999,9999,999*2],center=true);
	}
}

translate([0,30,0]) cylinder_clamp_v(30.5/2, 10, flat_width=24, mounting_bolt=4, flat_t=8);

cylinder_clamp(30.5/2, flat_width=24, mounting_bolt=4, flat_t=8,nut_trap=true);