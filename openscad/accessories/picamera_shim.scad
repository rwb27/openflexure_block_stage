shim_h=2;

intersection(){
    import("optics_module_rms_f50d13_nodovetail.stl");
    translate([0,0,-20.5]) cylinder(r=999,$fn=4, h=shim_h);
}