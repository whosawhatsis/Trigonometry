// File sinusoidhelicoid.scad 
// (c) 2023 Rich Cameron, for the book Make:Trigonometry
// Licensed under a Creative Commons, Attribution,
// CC-BY 4.0 international license, per
// https://creativecommons.org/licenses/by/4.0/
// Attribute to Rich Cameron, at
// repository github.com/whosawhatsis/Trigonometry

size = 18;
base = 100;

$fs = .2;
$fa = 2;

linear_extrude(5) {
	square([5, base], center = true);
	square([base, 5], center = true);
}

translate([0, 0, 5]) linear_extrude(size * 2 * PI, twist = 360) hull() {
	circle();
	translate([size, 0, 0]) circle();
}

cylinder(r = 2.5, h = 5 + size * 2 * PI);