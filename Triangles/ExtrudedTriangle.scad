// File ExtrudedTriangle.scad
//Creates a triangle with vertices at the three points shown.
// it is thickness thick (mm)

// (c) 2023 Rich Cameron, for the book Make:Trigonometry
// Licensed under a Creative Commons, Attribution,
// CC-BY 4.0 international license, per
// https://creativecommons.org/licenses/by/4.0/
// Attribute to Rich Cameron, at
// repository github.com/whosawhatsis/Trigonometry

thickness = 10;
 
linear_extrude(thickness)polygon([[0, 0], [64, 0],[64, 48]]);