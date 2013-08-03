// bee tube: 150mm long, 5/16" or 8mm diameter 

module bees(num=3, height=150, $fn=50) {
	inner_wall = 1.25;

	tube_r = 4.5; // make slightly larger than 8mm to account for shrinkage
	straw_r = tube_r + inner_wall/2;
	
	o=.1;

	dia= num * 2 - 1;
	outer_wall=5;
	squeeze= sin(60)* 2 * straw_r;
	x_adj = straw_r * 2;
	y_adj = squeeze;

	big_r = dia * (straw_r);
	big_r2 = big_r + outer_wall;

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
		translate([big_r2-straw_r - outer_wall,0,0]) {
			difference() {
				cylinder(r=big_r2, h=height, $fn=6);
				translate([0,0,7]) rotate_extrude(convexity = 10, $fn=6) {
					translate([big_r2,0]) circle(r=2, $fn=20);
				}
				translate([0,0,height-7]) rotate_extrude(convexity = 10, $fn=6) {
					translate([big_r2,0]) circle(r=2, $fn=20);
				}
			}
		}
	}

	module beebox() {
		difference() {
			box();
			tubes();
		}
	}

	module shroud(height=30) {
		rad = big_r2 + .5;
		difference() {
			union() {
				difference() {
					cylinder(r=rad+2, h=height, $fn=6);
					translate([0,0,-o]) cylinder(r=rad, h=height+2*o, $fn=6);
				}
				translate([0,0,14]) 
					intersection() {
						translate([0,0,-7]) cylinder(r=rad+2, h=10, $fn=6);
						rotate_extrude(convexity = 10, $fn=6) {
							translate([rad,0]) circle(r=2, $fn=20);
						}
					}
			}
			translate([rad*1.1,0,-o]) cylinder(r=rad,height+2*o,$fn=6);
		}
	}

	module base() {
		rad = big_r2 + .5;
		difference() {
			union() {
				cylinder(r=rad+5, h=2, $fn=6);
				translate([3,0,0]) cylinder(r=rad+5, h=2, $fn=6);
				// hanger
				translate([-(rad+5)*1.25,0,0]) 
					difference() {
						union() {
							translate([rad/3,0,0]) 
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
				// beebox shroud
				translate([-1.5,0,-5]) rotate([0,5,0]) 
					difference() {
						union() {
							difference() {
								cylinder(r=rad+2, h=25, $fn=6);
								translate([0,0,11]) cylinder(r=rad, h=20+o, $fn=6);
							}
							translate([0,0,7+2+4+6]) 
								intersection() {
									translate([0,0,-7]) cylinder(r=rad+2, h=10, $fn=6);
									rotate_extrude(convexity = 10, $fn=6) {
										translate([rad,0]) circle(r=2, $fn=20);
									}
								}
						}
						translate([rad/2.2,-rad,11]) cube([2*rad,2*rad,20*2]);
					}
				// beebox support bump
				translate([rad+3,0,0]) sphere(r=4);
			}
			translate([0,0,-50]) cylinder(r=rad*5,h=50);
		}
	}

	beebox();
	translate([95,55,0]) base();
	translate([95,-50,0]) shroud(50);

}

bees(num=4, height=100);