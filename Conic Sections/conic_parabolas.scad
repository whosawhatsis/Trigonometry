// File conic_parabolas.scad 
// (c) 2023 Rich Cameron, for the book Make:Trigonometry
// Licensed under a Creative Commons, Attribution,
// CC-BY 4.0 international license, per
// https://creativecommons.org/licenses/by/4.0/
// Attribute to Rich Cameron, at
// repository github.com/whosawhatsis/Trigonometry

h = 50; // height of cone, mm
n = 120;
r = h;  // radius of cone, mm

cuts = [10, 20, 40, 80];

rim = 2;

slicetilt = atan2(h, r);// angle of the cutting plane relative to cone base
 
_cuts = [for(i = cuts) i];

for(i = [0:len(_cuts) - 1]) //translate([(len(_cuts) - i) * (r * 2 + 1), 0, rim]) rotate((slicetilt > atan2(h, r)) ? [slicetilt, 0, 0] : 0) 
translate([0, _cuts[i] - 1 * (rim + 2) * (len(_cuts) - i), h]) rotate([slicetilt, 0, 0]) intersection() {
	shape(_cuts[i]);
	//%shape(_cuts[i]);
	difference() {
		hull() {
			translate([0, 0, -rim]) linear_extrude() intersection() {
				offset(-rim) projection(cut = true) shape(_cuts[i], oversize = true);
				offset(-rim) projection(cut = true) translate([0, 0, rim * 2]) shape(_cuts[i], oversize = true);
			}
			intersection() {
				linear_extrude(1000) square(1000, center = true);
				shape(_cuts[i]);
				//%shape(_cuts[i]);
			}
		}
		if(i) translate((_cuts[i] - _cuts[i - 1]) * [0, -cos(slicetilt), sin(slicetilt)]) hull() {
			translate([0, 0, -rim]) linear_extrude() intersection() {
				offset(-rim) projection(cut = true) shape(_cuts[i - 1], oversize = true);
				offset(-rim) projection(cut = true) translate([0, 0, rim * 2]) shape(_cuts[i - 1], oversize = true);
			}
			intersection() {
				linear_extrude(1000) square(1000, center = true);
				shape(_cuts[i - 1]);
				//%shape(_cuts[i - 1]);
			}
		}
	}
}

translate([0, max(_cuts), h]) rotate([slicetilt, 0, 0]) difference() {
	shape(max(_cuts));
	//%shape(max(_cuts));
	hull() {
		translate([0, 0, -rim]) linear_extrude() intersection() {
			offset(-rim) projection(cut = true) shape(max(_cuts), oversize = true);
			offset(-rim) projection(cut = true) translate([0, 0, rim * 2]) shape(max(_cuts), oversize = true);
		}
		intersection() {
			linear_extrude(1000) square(1000, center = true);
			shape(max(_cuts));
			//%shape(max(_cuts));
		}
	}
	linear_extrude(1000) square(1000, center = true);
}

module shape(sliceoffset = 0, oversize = false) rotate([-slicetilt, 0, 0]) translate([0, -sliceoffset, -h]) cylinder(r1 = oversize ? 2 * r : r, r2 = 0, h = oversize ? 2 * h : h, center = oversize, $fn = n);