/*
  Useful settings/parameters for the OpenFlexure fibre stage
*/
version_numstring = "0.2.1";
stage = [37,20,5]; // dimensions of stage part
beam_height = 75; // height of beam above the table
stage_to_beam_height = 12.5;
stage_height = beam_height - stage_to_beam_height; //bottom of base to top surface of the stage 
 // NB platform_z sets the distance from bottom of the body to top of the stage
 // stage_height determines the thickness of the base.
brim_r = 0;

// Range of travel is lever length * flex_a
xy_lever = 10;
z_lever = 10;

// Mechanical reduction settings
xy_stage_reduction = 30/xy_lever; //ratio of sample motion to lower shelf motion
xy_reduction = 50/xy_lever; //mechanical reduction from screw to sample
z_reduction = 50/z_lever; //mechanical reduction for Z

// Motor lugs
motor_lugs = true;

// Mounting holes
breadboard_lugs="diagonal"; //sets the hole pattern for bolting it down.  See the options below.

// Flexure dimensions - good for PLA and ~0.5mm nozzle
zflex = [6, 1.5, 0.75]; //dimensions of flexure
xflex = [5,5.5,5]; //default bounding box of x flexure
xflex_t = 1; //thickness of bendy bit in x
flex_a = 0.1; //angle through which flexures are bent, radians
dz = 0.5; //thickness before a bridge is printable-on

xy_travel = xy_lever * flex_a; //max. travel in X or Y
xy_bottom_travel = xy_travel * xy_stage_reduction; //travel of bottom of XY stage
xy_actuator_pivot_w = 25; //width of the hinge for the actuating lever
actuator_h = 26; //height of actuator columns (~screw length)

pushstick = [5,38,5]; //cross-section of XY "push stick"
pw = pushstick[0]; //because this is used in a lot of places...

wall_t = 1.6;
d=0.05;

// Height of the bridging "shelves" in the XY axis "table" structure
shelf_z1 = xy_lever * xy_stage_reduction;
shelf_z2 = shelf_z1 + xy_lever;

// Z axis geometry
z_travel = z_lever * flex_a; //max. travel in Z
z_stage_base_y = -stage[1]/2-xy_bottom_travel; //position of the flexure edge of the Z stage
z_stage_base_w = stage[0] + 2*zflex[1] - 2*xy_bottom_travel - 2; //width of the flexure edge of the Z stage
z_anchor_bottom_y = z_stage_base_y - z_lever - zflex[1]; // lower Z stage end of the fixed base
z_actuator_pivot_y = stage[1]/2 + zflex[1] + zflex[0] + xy_bottom_travel + wall_t;
z_actuator_pivot_w = 20; //width of the hinge for the Z actuator lever
z_pushstick_z = shelf_z1 - pw - 2.5; // height of the Z pushstick

// Mounting stuff
// By default, place 3 mounting holes to align the centre of the stage with a hole.
// setting beam_between_holes adds another set of holes, putting the beam halfway between
bolt_spacing = 25; // change to 25.4 for imperial tables
mounting_bolts_alongholes = [[-1,0,0],[0,-1,0],[1,0,0]]*1.5*bolt_spacing; //beam aligned with holes
mounting_bolts_betweenholes = [[-1.25,-0.25,0],[1.25,0.25,0],[-0.25,-1.25,0]]*1.41*bolt_spacing;
mounting_bolts_atsides = [[-1.5,0,0],[1.5,0,0],[-1.5,-1,0],[1.5,-1,0]] * bolt_spacing;
mounting_bolts_diagonal = concat(mounting_bolts_alongholes, 
                                 mounting_bolts_betweenholes);
// I hope you'll excuse the stacked ternaries, this is an unpleasant necessity :(
mounting_bolts = breadboard_lugs=="atsides"?mounting_bolts_sides:
                 breadboard_lugs=="diagonal"?mounting_bolts_diagonal:
                 breadboard_lugs=="alongholes"?mounting_bolts_alongholes:
                 breadboard_lugs=="betweenholes"?mounting_bolts_betweenholes:
                 /*breadboard_lugs=="none"?*/[];
            
platform_z = shelf_z2 + stage[2] + 7; // The platform is a fixed height above the moving stage
fixed_platform_standoff = 10;
fixed_platform = [50,40,4];
platform_gap = xy_travel + 1;
casing_top = shelf_z2 + stage[2] - z_travel; // top of the wall
max_actuator_travel = max(xy_travel*xy_reduction, z_travel*z_reduction); // maximum distance the actuators protrude below the stage
base_height = stage_height - platform_z; // the base takes up any height not use by the body.
if(base_height < max_actuator_travel + 4) echo("WARNING: stage_height is too low, base will not compile properly!");