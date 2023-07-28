// File simple_arm_sg90.scad 
// (c) 2023 Rich Cameron, for the book Make:Trigonometry
// Licensed under a Creative Commons, Attribution,
// CC-BY 4.0 international license, per
// https://creativecommons.org/licenses/by/4.0/
// Attribute to Rich Cameron, at
// repository github.com/whosawhatsis/Trigonometry

$fs = .2;
$fa = 2;

bicep_l = 50;
forearm_l = 50;

point = [75, 0, 50];

base();
translate([0, 0, 17]) {
	%servo();
	rotate(theta(point)) translate([0, 0, 11]) {
		%horn();
		shoulder();
		translate([0, -5, 11]) rotate([90, 0, 0]) {
			%servo();
			rotate(90 - shoulder(point)) translate([0, 0, 11]) {
				%horn();
				bicep();
				translate([bicep_l, 0, 0]) rotate([0, 180, 0]) {
					%servo();
					rotate(180 - elbow(point)) translate([0, 0, 11]) rotate(180) {
						%horn();
						forearm();
					}
				}
			}
		}
	}
}

function r(point) = sqrt(pow(point[0], 2) + pow(point[1], 2) + pow(point[2], 2));
function theta(point) = atan2(point[1], point[0]);
function phi(point) = acos(point[2] / r(point));
function elbow(point) = acos((pow(bicep_l, 2) + pow(forearm_l, 2) - pow(r(point), 2)) / (2 * bicep_l * forearm_l));
function shoulder(point) = phi(point) - asin(forearm_l * sin(elbow(point)) / r(point));

module base() difference() {
	union() {
		linear_extrude(10, convexity = 5) difference() {
			offset(4) offset(-4) for(a = [-45, 45]) rotate(a) square([10, 100], center = true);
			servo(true);
		}
		linear_extrude(17, convexity = 5) difference() {
			offset(2) translate([5.25, 0, 0]) square([23 + 5, 12.5], center = true);
			servo(true);
		}
	}
	translate([0, 0, 2]) rotate([0, -90, 0]) cylinder(r = 5, h = 20);
}

module shoulder() difference() {
	intersection() {
		linear_extrude(17, convexity = 5) difference() {
			offset(3) offset(-3.5) offset(.5) {
				square([50, 10], center = true);
				square([10, 22], center = true);
			}
			circle(3.8);
		}
		translate([0, 0, 11]) rotate([-90, 0, 0]) linear_extrude(100, center = true) hull() for(i = [0, 100]) translate([0, i, 0]) circle(25);
	}
	*translate([0, 0, -.1]) cylinder(r = 3.8, h = 5);
	horn(true);
	for(i = [1, -1]) translate([5.25 + i * 28/2, 0, 11]) rotate([90, 0, 0]) cylinder(r = 1, h = 50, center = true);

	translate([5.25, 0, 4.75]) linear_extrude(17) square([23, 50], center = true);
}

module bicep(l = bicep_l) difference() {
	linear_extrude(5, convexity = 5) difference() {
		offset(3) offset(-3.5) offset(.5) {
			square([43, 10], center = true);
			square([10, 22], center = true);
			hull() {
				circle(5);
				translate([l, 0, 0]) {
					circle(5);
				}
			}
			offset(2) translate([l - 5.25, 0, 0]) square([23 + 5, 12.5], center = true);
		}
		translate([l, 0, 0]) rotate(180) servo(true);
		circle(3.8);
	}
	*translate([0, 0, -.1]) cylinder(r = 3.8, h = 5);
	translate([0, 0, 4 - .4]) linear_extrude(50, convexity = 5) offset(1) offset(-1) {
		hull() {
			square([38, 4], center = true);
			square([4, 7], center = true);
		}
		square([4, 17], center = true);
	}
}

module forearm(l = forearm_l) difference() {
	intersection() {
		linear_extrude(5, convexity = 5) difference() {
			union() {
				offset(3) offset(-3.5) offset(.5) {
					square([43, 10], center = true);
					square([10, 22], center = true);
				}
				hull() {
					circle(5);
					translate([l, 0, 0]) scale([2, 1, 1]) rotate(135) square(5);
				}
			}
			circle(3.8);
		}
		union() {
			translate([l, 0, 5]) rotate([0, -90, 0]) cylinder(r1 = 0, r2 = l * 2 / 3, h = l, $fn = 4);
			cube(44, center = true);
		}
	}
	horn(true);
}

module horn(hole = false) if(!false) translate([0, 0, 5]) rotate([180, 0, 0]) {
	linear_extrude(1.4) offset(1) offset(-1) {
		hull() {
			square([38, 4], center = true);
			square([4, 7], center = true);
		}
		square([4, 17], center = true);
	}
	cylinder(r = 3.5, h = 4);
} else {
	
}

module servo(hole = false) if(!hole) {
	cylinder(r = 2.5, h = 14);
	cylinder(r = 6.25, h = 11);
	translate([6, 0, 0]) cylinder(r = 3, h = 11);
	translate([5.25, 0, 0]) {
		translate([0, 0, -23 + 6.5]) linear_extrude(23) square([23, 12.5], center = true);
		linear_extrude(2.5) difference() {
			square([32, 12.5], center = true);
			for(i = [1, -1]) translate([i * 28/2, 0, 0]) circle(1);
		}
	}
} else {
	translate([5.25, 0, 0]) {
		for(i = [1, -1]) translate([i * 28/2, 0, 0]) circle(1);
		square([28, .5], center = true);
		offset(.5) offset(-.5) square([25, 12.5], center = true);
	}
}