// File waves.scad, based on triangleMeshSurface.scad
// Creates a 3D surface z = f(x, y)
// (c) 2018-2023 Rich Cameron, for the book Make:Trigonometry
// Licensed under a Creative Commons, Attribution,
// CC-BY 4.0 international license, per
// https://creativecommons.org/licenses/by/4.0/
// Attribute to Rich Cameron, at
// repository github.com/whosawhatsis/Trigonometry

wave = "point_source"; // ["point_source", "plane_wave", "wave_sum", "wave_diff"]

lambda = 2;
amplitude = 2;

t = 1.2; //Thickness along z axis. t = 0 gives a flat base at z = 0
unit = 1;
range = [100, 100]; //Range of [x, y] values to graph. Also controls those dimensions of the exported model.
res = .5; //Surface resolution in mm. Higher numbers produce a smoother surface, but take longer to generate.
originmarker = 0; //radius of an octahedral cutout placed at [0, 0, 0] to mark the origin. Set to zero to disable.
blockymode = false;

function f(x, y) = ((
		(wave == "point_source" || wave == "wave_diff" || wave == "wave_sum") ?
			amplitude * sin(((180 / PI) / lambda) * r(x, y, 50, 0))
		:
			0
	) + (
		(wave == "wave_diff") ?
			-1
		:
			1
	) * (
		(wave == "plane_wave" || wave == "wave_diff" || wave == "wave_sum") ?
			amplitude * sin(((180 / PI) / lambda) * y)
		:
			0
	));

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