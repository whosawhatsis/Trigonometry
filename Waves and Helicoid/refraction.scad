// File refraction.scad 
// computes refraction of a wave into a medium
// (c) 2023 Rich Cameron, for the book Make:Trigonometry
// Licensed under a Creative Commons, Attribution,
// CC-BY 4.0 international license, per
// https://creativecommons.org/licenses/by/4.0/
// Attribute to Rich Cameron, at
// repository github.com/whosawhatsis/Trigonometry
//
// Based on triangleMeshSurface.scad
// Creates a 3D surface z = f(x, y)
// (c) 2018-2022 Rich Cameron, for the book Make:Calculus
// Licensed under a Creative Commons, Attribution,
// CC-BY 4.0 international license, per
// https://creativecommons.org/licenses/by/4.0/
// Attribute to Rich Cameron, at
// repository github.com/whosawhatsis/Calculus


//angle of the input wave (measured relative to the surface's normal vector)
angle_in = 45;
//wave peak amplitude
amplitude = 2;
//wavelenth / 2pi
lambda = 2 * 660 / 480;
//width of rays perpendicular to waves (0 to disable)
ray_width = 1;
refractive_index = 1.52;
//intensity of refracted wave (0 to disable)
refract = 1; // [0:.1:1]
//intensity of reflected wave (0 to disable)
reflect = 0; // [0:.1:1]

//Thickness along z axis. t = 0 gives a flat base at z = 0
t = 1.2;
//Surface resolution in mm. Higher numbers produce a smoother surface, but take longer to generate.
res = .5;

{}//editing the variables below is not recommended.

unit = 1;
//Range of [x, y] values to graph. Also controls those dimensions of the exported model.
range = [100, 100];
//radius of an octahedral cutout placed at [0, 0, 0] to mark the origin. Set to zero to disable.
originmarker = 0;
blockymode = false;


angle_refract = asin((1/refractive_index) * sin(angle_in));
angle_reflect = 180 - angle_in;

function wave_in(x, y) =
	(y > 50) ? 
		sin( (180/(PI*lambda)) * ((y-50) * cos(angle_in) - x * sin(angle_in)))
	:
		0;

function wave_refract(x, y) = 
	(y > 50) ?
		0
	:
		sin(180/(PI* lambda) * (refractive_index) * ((y-50) * cos(angle_refract) - x * sin(angle_refract)) );

function wave_reflect(x, y) =
	(y > 50) ?
		sin(180+180/PI / lambda * ((y-50) * cos(angle_reflect) - x * sin(angle_reflect) ))
	:
		0;



function f(x, y) = amplitude * (
	wave_in(x, y) + 
	reflect * wave_reflect(x, y) + 
	refract * wave_refract(x, y)
);

if(ray_width) intersection() {
	translate([0, 0, -100]) cube([range[0], range[1], 200]);
	union() {
		translate([50, 50, -t / 2]) rotate(angle_in) translate([0, 50, 0]) cube([ray_width, 100, t + 2 * amplitude], center = true);
		if(refract > 0) translate([50, 50, -t / 2]) rotate(180 + angle_refract) translate([0, 50, 0]) cube([ray_width, 100, t + 2 * amplitude * refract], center = true);
		if(reflect > 0) translate([50, 50, -t / 2]) rotate(180 + angle_reflect) translate([0, 50, 0]) cube([ray_width, 100, t + 2 * amplitude * reflect], center = true);
	}
}

s = [round((range[0] - res/2) / res), round(range[1] / res * 2 / sqrt(3))];
seg = [range[0] / (s[0] - .5), range[1] / s[1]];

function r(x, y, cx = range[0]/2, cy = range[1]/2) = sqrt(pow(cx - x, 2) + pow(cy - y, 2));
function theta(x, y, cx = range[0]/2, cy = range[1]/2) = atan2((cy - y), (cx - x));
function zeronan(n) = (n == n) ? n : 0;

points = concat(
	[for(y = [0:s[1]], x = [0:s[0]]) [
		seg[0] * min(max(x - (y % 2) * .5, 0), s[0] - .5),
		seg[1] * y,
		zeronan(f(seg[0] * min(max(x - (y % 2) * .5, 0), s[0] - .5), seg[1] * y))
	]], [for(y = [0:s[1]], x = [0:s[0]]) [
		seg[0] * min(max(x - (y % 2) * .5, 0), s[0] - .5),
		seg[1] * y,
		t ? zeronan(f(seg[0] * min(max(x - (y % 2) * .5, 0), s[0] - .5), seg[1] * y)) - t : 0
	]]
);
*for(i = points) translate(i) cube(.1, center = true);
	
function order(point, reverse) = [for(i = [0:2]) point[reverse ? 2 - i : i]];
function mirror(points, offset) = [for(i = [0, 1], point = points) order(point + (i ? [0, 0, 0] : [offset, offset, offset]), i)];

polys = concat(
	mirror(concat([
		for(x = [0:s[0] - 1], y = [0:s[1] - 1]) [
			x + (s[0] + 1) * y,
			x + 1 + (s[0] + 1) * y,
			x + 1 - (y % 2) + (s[0] + 1) * (y + 1)
		]
	], [
		for(x = [0:s[0] - 1], y = [0:s[1] - 1]) [
			x + (y % 2) + (s[0] + 1) * y,
			x + 1 + (s[0] + 1) * (y + 1),
			x + (s[0] + 1) * (y + 1)
		]
	]), len(points) / 2),
	mirror([for(x = [0:s[0] - 1], i = [0, 1]) order([
		x + (i ? 0 : 1 + len(points) / 2),
		x + 1,
		x + len(points) / 2
	], i)], len(points) / 2 - s[0] - 1),
	mirror([for(y = [0:s[1] - 1], i = [0, 1]) order([
		y * (s[0] + 1) + (i ? 0 : (s[0] + 1) + len(points) / 2),
		y * (s[0] + 1) + (s[0] + 1),
		y * (s[0] + 1) + len(points) / 2
	], 1 - i)], s[0])
);

//echo(points);

difference() {
	union() {
		if(blockymode) for(x = [0:res:range[0]], y = [0:res:range[1]]) translate([x, y, 0]) cube([res, res, f(x, y)]);
		else polyhedron(points, polys, convexity = 5);
	}
	if(originmarker) hull() for(i = [0, 1]) mirror([0, 0, i]) cylinder(r1 = originmarker, r2 = 0, h = originmarker, $fn = 4);
}