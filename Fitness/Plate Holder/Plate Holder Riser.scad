// Bond-optimized rib with glue channels & small bevel.
//
// Base dimensions: 84 x 10 x 12

$fn = 80;  // smoothness

// ---------- Parameters ----------
Rib_Length = 84;
Rib_Width = 10;
Rib_Height = 12;
Top_Bevel = 0.6;

module rib_bonded(x=Rib_Length, y=Rib_Width, z=Rib_Height) {
  difference() {
    // Main body with a small bevel (cheap chamfer using hull trick)
    // If you want absolute rectangular, set Top_Bevel=0 and simplify.
    if (Top_Bevel > 0) {
      hull() {
        translate([-x/2, -y/2, 0]) cube([x, y, z - Top_Bevel]);
        translate([-(x-2*Top_Bevel)/2, -(y-2*Top_Bevel)/2, z - Top_Bevel])
          cube([x-2*Top_Bevel, y-2*Top_Bevel, Top_Bevel]);
      }
    } else {
      translate([-x/2, -y/2, 0]) cube([x, y, z]);
    }

    // Underside glue channels (cut into the bottom face)
    y_pos = -y/2 + 2 + 0.5*(y - 2*2);
    channel_w = Rib_Width - 4;
    
    translate([-x/2 + 2, y_pos - channel_w/2, -0.01])
      cube([x - 2*2, channel_w, 0.8 + 0.02], center=false);
    
  }
}

rib_bonded();
