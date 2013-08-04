// bee tube: 150mm long, 5/16" or 8mm diameter

BEE_SHROUD="shroud";
BEE_BASE="base";
BEE_NEST="nest";

// default number of 4 is perfect for attaching to a 4x4 post

module bees(which, num=4, height=150, $fn=50) {
    inner_wall = 1.2;

    tube_r = 4.25; // make slightly larger than 8mm to account for shrinkage
    straw_r = tube_r + inner_wall/2;

    o=.1;

    dia= num * 2 - 1;
    outer_wall=5;
    squeeze= sin(60)* 2 * straw_r;
    x_adj = straw_r * 2;
    y_adj = squeeze;

    outer_radius = dia * straw_r + outer_wall;

    module tubes() {
        for (row = [ 0 : num - 1]) {
            assign(mirror=(row == 0) ? [1] : [-1,1])
            for (i = mirror) {
                for (col = [0 :dia - row -1]) {
                    assign(x = col * x_adj + row * x_adj/2, y = i * row * y_adj)
                        translate([x,y,-o]) cylinder(r=tube_r, h=height+2*o);
                }
            }
        }
    }

    module box() {
        translate([outer_radius-straw_r - outer_wall,0,0]) {
            difference() {
                cylinder(r=outer_radius, h=height, $fn=6);
                translate([0,0,7]) rotate_extrude(convexity = 10, $fn=6) {
                    translate([outer_radius,0]) circle(r=2, $fn=20);
                }
                if (height >= 20)
                    translate([0,0,height-7]) rotate_extrude(convexity = 10, $fn=6) {
                        translate([outer_radius,0]) circle(r=2, $fn=20);
                    }
            }
        }
    }

    module nest_box() {
        difference() {
            box();
            tubes();
        }
    }

    module shroud(height=50, ridge_height=14) {
        rad = outer_radius + .5;
        difference() {
            union() {
                difference() {
                    cylinder(r=rad+2, h=height, $fn=6);
                    translate([0,0,-o]) cylinder(r=rad, h=height+2*o, $fn=6);
                }
                translate([0,0,ridge_height])
                    intersection() {
                        translate([0,0,-7]) cylinder(r=rad+2, h=10, $fn=6);
                        rotate_extrude(convexity = 10, $fn=6) {
                            translate([rad,0]) circle(r=1.5, $fn=20);
                        }
                    }
            }
            translate([rad*1.1,0,-o]) cylinder(r=rad,height+2*o,$fn=6);
        }
    }

    module base() {
        rad = outer_radius + .5;
        difference() {
            union() {
                cylinder(r=rad+5, h=2, $fn=6);
                translate([3,0,0]) cylinder(r=rad+5, h=2, $fn=6);
                // hanger
                translate([-(rad+5)*1.25,0,0])
                    difference() {
                        union() {
                            translate([rad/3.5,0,0])
                                // this really needs to be a cube, to account for num >= 6
                                cylinder(r=16, h=2, $fn=6);
                            cylinder(r=16, h=2, $fn=6);
                        }
                        // hanger hole
                        translate([-2,0,-o]) union() {
                            translate([-4,0,0]) cylinder(r=2,h=5+2*o);
                            translate([4,0,0]) cylinder(r=4,h=5+2*o);
                            translate([-4,-2,0]) cube([8,4,5+2*o]);
                        }
                    }
                // nest_box shroud
                translate([-1.5,0,-5]) rotate([0,5,0])
                    union() {
                        cylinder(r=rad+2, h=11, $fn=6);
                        difference() {
                            shroud(30, 14+4); // should be h=30
                            // need to cut off a bit more than the shroud module does
                            translate([rad/2.2,-rad,0]) cube([2*rad,2*rad,20*2]);
                        }
                    }
                // nest_box support bump
                translate([rad+5.5,0,1]) sphere(r=2);
            }
            translate([0,0,-50]) cylinder(r=rad*5,h=50);
        }
    }

    if (which == BEE_NEST)
        nest_box();
    else if (which == BEE_BASE)
        base();
    else if (which == BEE_SHROUD)
        shroud(50);
    else {
        nest_box();
        translate([outer_radius*1.5,outer_radius*2,0]) base();
        translate([0,outer_radius*2,0]) shroud();
    }

}

bees(which="all", num=4, height=100);
//translate([-85,55,0]) bees(which=BEE_NEST, num=4, height=15);
