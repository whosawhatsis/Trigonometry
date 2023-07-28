// File cylindergraph.scad 
// (c) 2023 Rich Cameron, for the book Make:Trigonometry
// Licensed under a Creative Commons, Attribution,
// CC-BY 4.0 international license, per
// https://creativecommons.org/licenses/by/4.0/
// Attribute to Rich Cameron, at
// repository github.com/whosawhatsis/Trigonometry

function f(theta) = sin(theta);

2d = false;
r = 30;
wall = 1;
resolution = 3;
periods = 1.5;

$fs = resolution / 10;
$fa = resolution;
res = 360 / ceil(360 / resolution);

add = -min([for(i = [0:360  * periods]) f(i)]);

if(2d) rotate(90) difference() {
	offset(0) translate([0, -r * add, 0]) square(r * [2 * PI * periods, add * 2]);
	difference() {
		offset(.01) scale([r * PI / 180, r]) polygon(concat([[360 * periods, 0], [0, 0]], [for(a = [0:res:360 * periods]) [a, f(a) + add * 0]]));
		offset(-.01) scale([r * PI / 180, r]) polygon(concat([[360 * periods, 0], [0, 0]], [for(a = [0:res:360 * periods]) [a, f(a) + add * 0]]));
	}
	#translate([0, r * add * 0, 0]) {
		translate([r * PI, 0, 0]) square([2 * r * PI, .01], center = true);
		for(a = [0:45:360 * periods]) translate([a / 180 * r * PI, 0, 0]) square([.01, 10], center = true);
		for(a = [0:15:360 * periods]) translate([a / 180 * r * PI, 0, 0]) square([.01, 5], center = true);
		for(a = [0:5:360 * periods]) translate([a / 180 * r * PI, 0, 0]) square([.01, 2.5], center = true);
	}
	echo(str("length: ", periods * r * 2 * PI, "mm (", periods * r * 2 * PI / 25.4, "in)"));
} else {
	for(a = [0:res:360 * periods - res]) hull() for(a = [a, a + res]) rotate(a) translate([r, 0, 0]) rotate([90, 0, 0]) linear_extrude(.001, center = true) {
		translate([-wall / 2, 0, 0]) square([wall, r * (f(a) + add) + wall * 5]);
	}

	for(a = [0:res:360 * periods - res]) hull() for(a = [a, a + res]) rotate(a) translate([r, 0, 0]) rotate([90, 0, 0]) {
		translate([0, r * (f(a) + add) + wall * 5, 0]) sphere(wall * 2);
	}

	*for(a = [0:res:360 - res]) hull() for(a = [a, a + res]) rotate(a) translate([r, 0, 0]) rotate([90, 0, 0]) {
		translate([0, r * (min(0, f(a)) + add) + wall * 5, 0]) rotate(90) sphere(wall * 1.5, $fn = 6);
	}


	linear_extrude(r * add + wall * 5) circle(r);
	linear_extrude(r * add + wall * 5 + .4) intersection() {
		*circle(r);
		union() {
			for(a = [0, 90]) rotate(a) square([wall, r * 2], center = true);
			for(a = [0:45:359]) rotate(a) translate([-wall / 2, r - 10, 0]) square([wall, 10 + wall]);
			for(a = [0:15:359]) rotate(a) translate([-wall / 2, r - 5, 0]) square([wall, 5 + wall]);
			*for(a = [0:5:359]) rotate(a) translate([-wall / 2, r - 2.5, 0]) square([wall, 2.5 + wall]);
			translate([r / 2, 0, 0]) circle(wall * 3, $fn = 3);
		}
	}
}