handle_r = 25;
handle_base_h = 3;
base_roundness_r = 3;

dome_r = 70;

shaft_r = 8;
shaft_sides = 6;
shaft_h = 40;

centerhole_r = 4;

screw_h = 32;
screw_r = 5 / 2;

nut_r = 8/2;
nut_h = 5;

extension_h = 11;
extension_r = 12/2;

// "speck" to keep object centered for slic3r infill pattern
speck_size = 0.3;

if(shaft_h <= screw_h + handle_base_h + 2) {
    error("Screw won't fit");
}

//

dome_center_depth = sqrt(dome_r * dome_r - handle_r * handle_r);

nut_pos = screw_h * 2 / 3 + handle_base_h;

module shape(n=6, r=handle_r, roundness_r=base_roundness_r) {
    if(n==0) {
        cylinder(dome_r, r=handle_r, $fn=200);
    }else{
        union() {
            for(i=[0:n]) {
                echo(i);
                hull() {
                    rotate(i*360/n)
                        translate([r,0,0])
                        cylinder(dome_r, r=base_roundness_r, $fn=40);
                    rotate((i+1)*360/n)
                        translate([r,0,0])
                        cylinder(dome_r, r=base_roundness_r, $fn=40);
                    cylinder(dome_r, r=base_roundness_r);
                }
                if(n % 2 != 0) {
                    rotate((i+0.5)*360/n)
                        translate([r + base_roundness_r - speck_size,0,0])
                        cylinder(speck_size, r=speck_size, $fn=12);
                }
            }
        }
    }
}

module handle_shape(n=6) {
    union() {
        intersection() {
            shape(n=n);
            translate([0,0,-dome_center_depth + handle_base_h])
                sphere(dome_r, $fn=100);
        }

        rotate([0,0,360/6/2])
            linear_extrude(height=shaft_h)
            circle(shaft_r, $fn=shaft_sides);

        cylinder(shaft_h + extension_h, r=extension_r);
    }
}

module _nut() {
    linear_extrude(height=nut_h)
        circle(nut_r, $fn=6);
}

module hole() {
    union() {
        translate([0, 0, handle_base_h - 1])
            cylinder(shaft_h + extension_h, r=screw_r, $fn=20);

        hull() {
            translate([0, 0, nut_pos]) _nut();
            translate([handle_r, 0, nut_pos]) _nut();
        }

        hull() {
            translate([0, -screw_r, nut_pos + nut_h])
                cube([nut_h/1000, screw_r*2, nut_r]);
            translate([screw_r, -screw_r, nut_pos + nut_h-1])
                cube([1, screw_r*2, 1]);
        }
    }
}

module handle(n=6) {
    difference() {
        handle_shape(n=n);
        hole();
    }
}

handle(5);
