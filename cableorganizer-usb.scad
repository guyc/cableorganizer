// Parametric USB Cable Organizer - GuyC

// note that with default replicatorG 1-extra-shell, 10% infill
// options the fingers formed by these rings will get a shell
// but no infill, so you can see through them.  I'm happy with
// that, but you may not be.

// Dimensions for the ring

ringInnerRadius = 4.2;     // radius of hole
ringThickness   = 1.5;     // wall thickness of rings
ringPadding     = 0.0;     // extra spacing between rings
ringNotch       = 4.4;     // notch wide enough to let cable pass through
ringOuterRadius = ringInnerRadius + ringThickness;

// Dimensions for the buttressed wall-attachment brackets

bracketHeight      = 10.0;  
bracketWidth       = 14.0;  // suggest 2*ringOuterRadius+ringPadding+bracketWall/2
bracketWall        =  2.0;  // thickness of back wall and buttresses
bracketBaseOffset  =  7.0;  // offset of base of buttress
bracketSlotWidth   =  4.4;  // wide enough for shaft of screw
bracketSlotDepth   =  5.0;  // suggest bracketHeight/2

// Overall platform size is determined by the depth and number of rings

platformDepth      =  4.0;  // thickness of platform
noRings            = 10;    // number of rings


function ringOrigin(i) = [bracketBaseOffset+ringOuterRadius,ringOuterRadius+(ringOuterRadius*2+ringPadding)*i,-platformDepth];

// support()
// Triangular buttress for supporting bracket.

module support()
{
    polyhedron (
	    points = [
 			[0, 0, bracketHeight],
           [0, bracketWall, bracketHeight], 
           [0, bracketWall, 0], 
           [0, 0, 0],
           [bracketBaseOffset, 0, 0],
           [bracketBaseOffset, bracketWall, 0]
        ],
        triangles = [[0,3,2],
                     [0,2,1],
                     [3,0,4],
                     [1,2,5], 
                     [0,5,4],
                     [0,1,5],
                     [5,2,4],
                     [4,2,3],
     ]);
}

// bracket(i)
// Bracket with buttresses and screw slot positioned
// so that it is aligned with the ith ring.  i MUST
// be >=0 and < noRings, but will overhang the platform
// slightly in the first and last positions, so I recommend
// i=1 and i=noRings-2.

// note that the negative geometries for the screw hole extend
// 1mm either side of the bracket to avoid co-incident faces.

module bracket(i)
{

	y = ringOrigin(i)[1];
    translate([0,y,0]) {
  	  difference() {
		// back wall
		translate([0, -bracketWidth/2,0]) 
			cube(size=[bracketWall, bracketWidth, bracketHeight], center=false);
		union() {
			// hole for slot
			translate([-1,0,bracketHeight-bracketSlotDepth]) 
			{
				rotate([0,90,0]) 
	       			cylinder(h=bracketWall+2,r=bracketSlotWidth/2,$fs=0.1);
			}
			// slot
			translate([0,-bracketSlotWidth/2,bracketHeight-bracketSlotDepth])
				cube(size=[bracketWall+2, bracketSlotWidth, bracketSlotDepth], center=false);
		}
	  }

  	  // left support
     translate([bracketWall,-bracketWidth/2,0])
		support();
	 // right support
     translate([bracketWall,bracketWidth/2-bracketWall,0])
		support();
	}
}

// platform()
// The rectangular body of the platform.

module platform()
{
	translate([0,0,-platformDepth])
		cube(size=[bracketBaseOffset+ringOuterRadius, noRings*2*ringOuterRadius+(noRings-1)*ringPadding, platformDepth]);
}

// ringPositive(i)
// The positive geometry of the ith ring which will be added to the platform()

module ringPositive(i)
{	translate(ringOrigin(i))
		cylinder(h=platformDepth, r=ringOuterRadius, $fs=0.1);
}

// ringNegative(i)
// The negative geometry of the ith ring which will be subtracted from the platform()
// Note that we arbitrarily extend this 2mm above and below the positive geometry
// to ensure that we do not have co-incident faces.

module ringNegative(i)
{
	translate(ringOrigin(i)) {
		translate([0,0,-1]) {
			union() {
				cylinder(h=platformDepth+2, r=ringInnerRadius, $fs=0.1);
				translate([ringOuterRadius/2,0,platformDepth/2+1])
					cube(size=[ringOuterRadius+1,bracketSlotWidth,platformDepth+2], center=true);
			}
		}
	}
}


// FINAL GEOMETRY
// We construct the platform and the positive ring geometry, then
// remove the negative ring geometry.

difference() {
	union() {
		platform();
		for(i = [0 : noRings-1]) {
			ringPositive(i);
		}
	}
	union() {
		for(i = [0 : noRings-1]) {
			ringNegative(i);
		}
	}
}
// brackets at 2nd and 2nd last position
bracket(1);
if (noRings>3) bracket(noRings-2);
