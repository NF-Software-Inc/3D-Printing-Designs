// Floor Plate Holder
//
// - Base (PLA-CF/PET‑CF): flat top, corner universal holes, vertical peg, gussets
// - TPU Feet (TPU): press-fit from top, flush cap, snap barb, grippy pad
// - Wall Inserts (PETG/PET‑CF): press-fit body + top flange (built-in washer), bolt passthrough
//
// Selector: set make = "base", "foot", or "insert" then F6 → Export STL

// -------- OUTPUT SELECTOR --------
make = "base";  // "base" | "foot" | "insert"

// -------- QUALITY --------
$fn = 220;

// -------- PEG --------
Plate_Hole_Diameter    = 51.0;
Peg_Clearance          = 2.2;
Peg_Diameter           = Plate_Hole_Diameter - Peg_Clearance; // ~48.8
Peg_Length             = 180;
Peg_Tip_Height         = 5.0;
Peg_Tip_Step           = (Peg_Clearance - 0.2)/2;

// -------- BASE (floor plate) --------
Base_Width              = 180;
Base_Length             = 220;
Base_Thickness          = 16;
Base_Corner_Radius      = 12;

Hole_Diameter           = 18.0;
Hole_Edge_Spacing       = 18.0;  // from side edges

// -------- GUSSETS --------
Use_Gussets             = 0;
Gusset_Thickness        = 8.0;
Gusset_Length           = (Base_Width / 2) - 20.0;
Gusset_Inner            = Gusset_Length - 20.0;
Gusset_Chamfer          = 6.0;

// -------- LOAD DISTRIBUTION RAILS --------
Use_Load_Rails          = 1;     // 0/1 enable
Rail_Width              = 10.0;  // rail "inboard" width from the outer edge
Rail_Edge_Spacing       = 48.0;  // how much to leave empty near each corner along edges

// -------- WALL INSERT (flanged, built-in washer) --------
Insert_Flange_Diameter   = 36.0;
Insert_Flange_Thickness  = 2.4;
Insert_Body_Diameter     = Hole_Diameter - 0.3;  // press-fit body (tighten/loosen per printer)
Insert_Body_Height       = Base_Thickness - 0.6;      // body depth in the hole
Insert_Bolt_Diameter     = 8.5;      // clearance for ~M8 / 5/16" lag (adjust as needed)

// -------- HELPERS --------
module rounded_rect_2d(w, h, r) {
  r = min(r, w/2, h/2);
    
  hull() {
    translate([ w/2 - r,  h/2 - r]) circle(r=r);
    translate([-w/2 + r,  h/2 - r]) circle(r=r);
    translate([ w/2 - r, -h/2 + r]) circle(r=r);
    translate([-w/2 + r, -h/2 + r]) circle(r=r);
  }
}

function corner_positions() = [
  [ Base_Width/2 - Hole_Edge_Spacing,  Base_Length/2 - Hole_Edge_Spacing],
  [-Base_Width/2 + Hole_Edge_Spacing,  Base_Length/2 - Hole_Edge_Spacing],
  [ Base_Width/2 - Hole_Edge_Spacing, -Base_Length/2 + Hole_Edge_Spacing],
  [-Base_Width/2 + Hole_Edge_Spacing, -Base_Length/2 + Hole_Edge_Spacing]
];

// -------- COMPONENTS --------
module floor_base() {
  difference() {
    linear_extrude(height = Base_Thickness)
      rounded_rect_2d(Base_Width, Base_Length, Base_Corner_Radius);

    // Universal corner holes (through-only)
    for (p = corner_positions()) {
      translate([p[0], p[1], 0])
        cylinder(d = Hole_Diameter, h = Base_Thickness + 0.08);
    }
  }
}

module vertical_peg() {
  base_fillet_h   = 12.0;
  base_fillet_w   = 7.0;
    
  union() {
    translate([0,0, Base_Thickness])
      cylinder(h = base_fillet_h,
               d1 = Peg_Diameter + 2*base_fillet_w,
               d2 = Peg_Diameter);
    translate([0,0, Base_Thickness + base_fillet_h])
      cylinder(h = Peg_Length - base_fillet_h, d = Peg_Diameter);
    
    translate([0,0, Base_Thickness + Peg_Length - Peg_Tip_Height])
      cylinder(h = Peg_Tip_Height + 0.04, d = Peg_Diameter + 2*Peg_Tip_Step);
  }
}

module gussets() {
  for (ang = [0, 90, 180, 270]) {
    rotate([0,0,ang]) translate([0,0, Base_Thickness])
      linear_extrude(height = Gusset_Thickness)
        polygon(points = [
          [0, 0],
          [Gusset_Length, 0],
          [Gusset_Length, Gusset_Inner - Gusset_Chamfer],
          [Gusset_Length - Gusset_Chamfer, Gusset_Inner],
          [0, Gusset_Inner]
        ]);
  }
}

// TPU foot (top-flush, snap barb, bottom pad)
module tpu_foot() {
  tpuf_ribs       = 6;
  tpuf_rib_h      = 0.6;
  tpuf_pad_d      = Hole_Diameter + 10.0;
  tpuf_pad_h      = 3.5;
    
  cap_t           = 1.0;
  stem_d          = Hole_Diameter - 0.8;
  stem_h          = Base_Thickness - cap_t;
  neck_d          = Hole_Diameter - 0.6;
  barb_h          = 2.5;
  barb_over       = 0.6;
    
  union() {
    cylinder(d = Hole_Diameter - 0.3, h = cap_t);
    translate([0,0, -0.04]) cylinder(d = neck_d, h = 1.2);
    translate([0,0, -barb_h])
      cylinder(h = barb_h, d1 = Hole_Diameter + barb_over, d2 = Hole_Diameter - 0.4);
    translate([0,0, -(stem_h + barb_h)])
      cylinder(d = stem_d, h = stem_h + barb_h);
    translate([0,0, -(stem_h + barb_h + tpuf_pad_h)])
      difference() {
        cylinder(d = tpuf_pad_d, h = tpuf_pad_h);
        for (i = [0:tpuf_ribs-1]) {
          rotate([0,0, i*(360/tpuf_ribs)])
            translate([0,0,-0.04])
              cube([tpuf_pad_d, 1.2, tpuf_rib_h + 0.04], center=true);
        }
      }
  }
}

// Wall insert with top flange (built-in washer)
module wall_insert() {
  anti_rot_flat_w   = 1.0;
  insert_csk_d      = Insert_Bolt_Diameter * 2;
  insert_csk_h      = Insert_Flange_Thickness + 0.5;
    
  difference() {
    // Outer flange + body
    union() {
      // Flange on top surface
      cylinder(d = Insert_Flange_Diameter, h = Insert_Flange_Thickness);
      // Press-fit body that fills the hole
      translate([0,0, -Insert_Body_Height])
      // Anti-rotation flats
      minkowski() {
        cylinder(d = Insert_Body_Diameter - anti_rot_flat_w, h = Insert_Body_Height + 0.04);
        cube([anti_rot_flat_w, anti_rot_flat_w, 0.04], center=true);
      }
    }

    // Bolt path through
    translate([0,0, -Insert_Body_Height - 0.04])
      cylinder(d = Insert_Bolt_Diameter, h = Insert_Flange_Thickness + Insert_Body_Height + 0.08);

    // Head recess inside the flange if desired
    translate([0,0, 0])
      cylinder(h = insert_csk_h + 0.04, d1 = insert_csk_d, d2 = Insert_Bolt_Diameter);    
  }
}

// Raised mid-side perimeter rails (top surface only)
// Top of rail aligns with top of peg flare: z = Base_Thickness + base_fillet_h
module load_rails() {
  rail_h = 12.0;  // raise base top up to chamfer/flare top

  translate([0, 0, Base_Thickness])
    linear_extrude(height = rail_h)
      difference() {

        // Keep rails inside the rounded-rectangle outline
        intersection() {
          rounded_rect_2d(Base_Width, Base_Length, Base_Corner_Radius);

          // Six mid-side strips, shortened so corners remain clear
          union() {
            // Top edge strips
            translate([0,  Base_Length/2 - Rail_Width/2])
              square([Base_Width - 2*Rail_Edge_Spacing, Rail_Width], center = true);
              
            translate([0,  Base_Length/2 - Rail_Width/2 - 25])
              square([Base_Width - 2*Rail_Edge_Spacing, Rail_Width], center = true);
              
            translate([0,  Base_Length/2 - Rail_Width/2 - 50])
              square([Base_Width - 2*Rail_Edge_Spacing, Rail_Width], center = true);

            // Bottom edge strips
            translate([0, -Base_Length/2 + Rail_Width/2])
              square([Base_Width - 2*Rail_Edge_Spacing, Rail_Width], center = true);
              
            translate([0, -Base_Length/2 + Rail_Width/2 + 25])
              square([Base_Width - 2*Rail_Edge_Spacing, Rail_Width], center = true);
              
            translate([0, -Base_Length/2 + Rail_Width/2 + 50])
              square([Base_Width - 2*Rail_Edge_Spacing, Rail_Width], center = true);
          }
        }

        // Explicit keep-out around universal corner holes (prevents TPU cap collision)
        for (p = corner_positions())
          translate([p[0], p[1]])
            circle(d = Hole_Diameter + 3);
      }
}

// -------- ASSEMBLY --------
module floor_plate_holder() {
  difference() {
    union() {
      floor_base();
      if (Use_Load_Rails) load_rails();
      vertical_peg();
      if (Use_Gussets) gussets();
    }
  }
}

// -------- OUTPUT --------
if (make == "base") {
  floor_plate_holder();
  echo("Export: BASE (PET‑CF)");
} else if (make == "foot") {
  tpu_foot();
  echo("Export: TPU FOOT");
} else if (make == "insert") {
  wall_insert();
  echo("Export: WALL INSERT (flanged)");
} else {
  echo("Set make = \"base\", \"foot\", or \"insert\".");
}
