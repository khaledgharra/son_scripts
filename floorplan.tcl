#============================================================
# i2c_master_top — Floorplan + Power Planning
# Matches GUI settings from screenshots exactly
# Usage:  source floorplan.tcl
#============================================================

puts "=== STEP 1: Floorplan ==="
floorPlan -site CoreSite -d 1799.84 1799.84 75.6 75.6 75.04 75.04

puts "=== STEP 2: Connect global power/ground nets ==="
source glnets.src
deselectAll

puts "=== STEP 3: Add power ring ==="
# M5 top/bottom: M5 is H-preferred → horizontal ring segments match M5 direction
# M4 left/right:  M4 is V-preferred → vertical ring segments match M4 direction
# No TOP_M used anywhere → avoids IO pad TOP_M bus bar conflicts
setAddRingMode \
    -ring_target default \
    -extend_over_row 0 \
    -ignore_rows 0 \
    -avoid_short 0 \
    -skip_crossing_trunks none \
    -stacked_via_top_layer M5 \
    -stacked_via_bottom_layer M1 \
    -orthogonal_only true \
    -skip_via_on_pin { standardcell } \
    -skip_via_on_wire_shape { noshape }

addRing \
    -nets {VDD VSS} \
    -around default_power_domain \
    -layer {top M5 bottom M5 left M4 right M4} \
    -width 6 \
    -spacing 1.8 \
    -center 1 \
    -jog_distance 0.56 \
    -threshold 0.56

puts "=== STEP 4: Add vertical power stripes (M4) ==="
# M4 V stripes connect at top/bottom to M5 ring via M4→M5 vias (no TOP_M)
addStripe \
    -nets {VDD VSS} \
    -layer M4 \
    -direction vertical \
    -width 6 \
    -spacing 1.8 \
    -set_to_set_distance 100 \
    -start_from left \
    -stacked_via_top_layer M5 \
    -stacked_via_bottom_layer M1

puts "=== STEP 5: Route power to standard cell pins ==="
sroute \
    -connect { corePin padRing } \
    -layerChangeRange { M1 M5 } \
    -blockPinTarget { nearestTarget } \
    -padPinPortConnect { allPort } \
    -nets { VDD VSS }

puts "=== Floorplan + Power Planning DONE ==="
puts "Next: placeDesign, then routeDesign"
