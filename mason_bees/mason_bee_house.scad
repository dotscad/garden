/**
 * mason_bee_house.scad
 *
 * A parametric module to generate a hexagonal nesting house for
 * [Orchard Mason Bees](http://en.wikipedia.org/wiki/Orchard_mason_bee).
 *
 * This prints in 3 parts so that it can be broken down for storage, and for easy access
 * to the nest holes for cleaning.  Being able to disconnect the nest from the base also
 * allows it to be easily moved to different pollination zones or under cover for winter
 * storage.  Along with the shroud, the slight downward tilt of the nest is intended to
 * keep the nest protected from rain/moisture.
 *
 * The holes diameter (5/16" or 8mm) is based on the paper tubes sold by
 * [Knox Cellars](http://www.knoxcellars.com/), which they describe as the most optimal
 * size for the bees.
 *
 * The default 15cm height value is intended to fit the paper tubes made/sold by Knox
 * Cellars.  These are not required but if used properly can contribute to the overall
 * health of your bee colony.  If your printer can print the full height, I would
 * encourage you to do so and use the paper tubes.
 *
 * This openSCAD library is part of the [dotscad](https://github.com/dotscad/dotscad)
 * project.
 *
 * @copyright  Chris Petersen, 2013
 * @license    http://creativecommons.org/licenses/LGPL/2.1/
 * @license    http://creativecommons.org/licenses/by-sa/3.0/
 *
 * @see        http://www.thingiverse.com/thing:179830
 * @source     https://github.com/dotscad/garden/blob/master/mason_bees/mason_bee_house.scad
 */

/* ******************************************************************************
 * Customizer parameters and rendering
 * ****************************************************************************** */

/* [Global] */

// Height of the main nest.  150mm fits the paper tubes sold by Knox Cellars
nest_height = 150; // [50:150]

// Number of nest holes per side.  4 is perfect for attaching to a 4x4 post
nest_holes = 4; // [2:8]

// Part to print
which_part="All"; // [All,Nest,Base,Shroud]

/* [Hidden] */

// Render the part(s)
mason_bee_house(which_part=which_part, nest_holes=nest_holes, nest_height=nest_height);

/* ******************************************************************************
 * Main module code below:
 * ****************************************************************************** */

/**
 * Renders some or all parts of a mason bee house/nest.
 * @param int    height Height of the nest, in mm
 * @param int    num    Number of nest holes per side of the hexagonal nest
 * @param string which  Which part or parts to render (All,Nest,Base,Shroud)
 */
module mason_bee_house(nest_height=150, nest_holes=4, which_part="All", $fn=25) {
    inner_wall = 1.2;

    tube_r = 4.25; // make slightly larger than 8mm to account for shrinkage
    straw_r = tube_r + inner_wall/2;

    o=.1;

    dia= nest_holes * 2 - 1;
    outer_wall=5;
    squeeze= sin(60)* 2 * straw_r;
    x_adj = straw_r * 2;
    y_adj = squeeze;

    outer_radius = dia * straw_r + outer_wall;

    module tubes() {
        for (row = [ 0 : nest_holes - 1]) {
            assign(mirror=(row == 0) ? [1] : [-1,1])
            for (i = mirror) {
                for (col = [0 :dia - row -1]) {
                    assign(x = col * x_adj + row * x_adj/2, y = i * row * y_adj)
                        translate([x,y,-o]) cylinder(r=tube_r, h=nest_height+2*o);
                }
            }
        }
    }

    module box() {
        translate([outer_radius-straw_r - outer_wall,0,0]) {
            difference() {
                cylinder(r=outer_radius, h=nest_height, $fn=6);
                translate([0,0,7]) rotate_extrude(convexity = 10, $fn=6) {
                    translate([outer_radius,0]) circle(r=2, $fn=20);
                }
                if (nest_height >= 20)
                    translate([0,0,nest_height-7]) rotate_extrude(convexity = 10, $fn=6) {
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

    module shroud(nest_height=50, ridge_height=14) {
        rad = outer_radius + .5;
        difference() {
            union() {
                difference() {
                    cylinder(r=rad+2, h=nest_height, $fn=6);
                    translate([0,0,-o]) cylinder(r=rad, h=nest_height+2*o, $fn=6);
                }
                translate([0,0,ridge_height])
                    intersection() {
                        translate([0,0,-7]) cylinder(r=rad+2, h=10, $fn=6);
                        rotate_extrude(convexity = 10, $fn=6) {
                            translate([rad,0]) circle(r=1.5, $fn=20);
                        }
                    }
            }
            translate([rad*1.1,0,-o]) cylinder(r=rad,nest_height+2*o,$fn=6);
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
                        hull() {
                            translate([rad/3.5,0,0])
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

    // Render the requested part(s)
    if (which_part == "Nest")
        nest_box();
    else if (which_part == "Base")
        base();
    else if (which_part == "Shroud")
        shroud(50);
    else {
        nest_box();
        translate([outer_radius*1.5,outer_radius*2,0]) base();
        translate([0,outer_radius*2,0]) shroud();
    }

}

