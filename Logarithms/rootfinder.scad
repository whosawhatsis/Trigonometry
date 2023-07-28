// File rootfinder.scad 
// (c) 2023 Rich Cameron, for the book Make:Trigonometry
// Licensed under a Creative Commons, Attribution,
// CC-BY 4.0 international license, per
// https://creativecommons.org/licenses/by/4.0/
// Attribute to Rich Cameron, at
// repository github.com/whosawhatsis/Trigonometry

2d = false;
max = 10;
scale = 150;
root = 3;
w = 5;
h = 10;
notch = .5;

rotate(90) if(2d) difference() {
	translate([-1, 0, 0]) square([scale + 2, h]);
	#union() for (j = [0:root - 1], i = [1:max]) {
		translate([(scale / root) * (log(i) + j), h, 0]) square([.0001, h], center = true);
	}
	#union() for (j = [0:root - 1], i = [1:.5:max]) {
		translate([(scale / root) * (log(i) + j), h, 0]) square([.0001, h / 2], center = true);
	}
} else {
	linear_extrude(h / 2) difference() {
		translate([-1, 0, 0]) square([scale + 2, w]);
		union() for (j = [0:root - 1], i = [1:max]) {
			translate([(scale / root) * (log(i) + j), 0, 0]) circle(notch, $fn = 4);
		}
	}
	linear_extrude(h) difference() {
		translate([-1, 0, 0]) square([scale + 2, w]);
		union() for (j = [0:root - 1], i = [1:.5:max]) {
			translate([(scale / root) * (log(i) + j), 0, 0]) circle(notch, $fn = 4);
		}
	}
}