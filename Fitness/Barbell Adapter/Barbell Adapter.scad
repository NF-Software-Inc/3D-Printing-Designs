// Barbell adapter with precise top chamfers (outer & inner).
//
// How it works:
//
// We define one 2D polygon that traces the ring cross-section:
//   outer boundary from bottom to top, then inner boundary from top to bottom.
//   rotate_extrude() spins that ring to create the solid.

$fn = 256;  // smoothness

// ---------- Parameters ----------
Outer_Diameter_Lip   = 65;
Outer_Diameter_Body  = 51;
Outer_Diameter_Top   = Outer_Diameter_Body - 4;

Height_Lip   = 3;
Height_Body   = 35;   // top after outer chamfer
Height_Chamfer = Height_Body - 2;   // start of chamfer region

Inner_Diameter_Base  = 25.6;               // inner diameter below chamfer
Inner_Diameter_Top   = Inner_Diameter_Base + 4;               // inner diameter at the very top (after chamfer)

R_lip    = Outer_Diameter_Lip/2;           // 32.5
R_body   = Outer_Diameter_Body/2;          // 25.5
R_outerT = Outer_Diameter_Top/2;           // 23.5
R_in     = Inner_Diameter_Base/2;          // 12.8
R_inT    = Inner_Diameter_Top/2;           // 14.8

// ---------- Print options ----------
PRINT_LIP_ONLY = false;   // <--- set true to print only the lip

// A little extra margin so the cropping box always fully covers the part
CROP_MARGIN = 1;         // mm

module profile_ring_2d() {
    // Points define the annular cross-section (outer up, inner down).
    // X = radius (mm), Y = height (mm)
    pts = [
        // --- Outer boundary (bottom → top) ---
        [R_lip,     0],          // bottom of lip (Ø65 @ Z=0)
        [R_lip,     Height_Lip],      // top of lip (Z=3)
        [R_body,    Height_Lip],      // step inward to main body radius
        [R_body,    Height_Chamfer],    // vertical outer wall up to Z=33
        [R_outerT,  Height_Body],      // outer 45° chamfer to Ø47 at Z=35

        // --- Inner boundary (top → bottom) ---
        [R_inT,     Height_Body],      // inner at top Ø29.6 @ Z=35
        [R_in,      Height_Chamfer],    // inner 45° chamfer down to Ø25.6 @ Z=33
        [R_in,      0]           // inner wall straight down to Z=0
        // Polygon auto-closes back to first point (R_lip,0)
        // forming the bottom face (lip).
    ];

    polygon(points = pts);
}

module full_part() {
    rotate_extrude(angle = 360)
        profile_ring_2d();
}

module lip_only() {
    // Keep only Z = [0 .. Height_Lip]
    // We intersect the full model with a tall-enough cylinder/box slice.
    // Using a cube is simplest and robust.
    intersection() {
        full_part();

        // Crop volume: big square slab from Z=0 to Z=Height_Lip
        // Make it wider than the max diameter.
        translate([-(R_lip + CROP_MARGIN), -(R_lip + CROP_MARGIN), 0])
            cube([2*(R_lip + CROP_MARGIN), 2*(R_lip + CROP_MARGIN), Height_Lip], center=false);
    }
}

// ---------- Output ----------
if (PRINT_LIP_ONLY)
    lip_only();
else
    full_part();
