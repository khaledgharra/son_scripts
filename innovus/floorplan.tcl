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
# M5 top/bottom (horizontal), M4 left/right (vertical)
# TOP_M avoided — conflicts with IO pad bus bars
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
# ybottom/ytop_offset keeps stripes inside core boundary (avoids pad cell blockages)
addStripe \
    -nets {VDD VSS} \
    -layer M4 \
    -direction vertical \
    -width 4 \
    -spacing 1.8 \
    -set_to_set_distance 100 \
    -start_from left \
    -stacked_via_top_layer M5 \
    -stacked_via_bottom_layer M4 \
    -ybottom_offset 75.04 \
    -ytop_offset 75.04

puts "=== STEP 5: Route power to standard cell pins ==="
# padPinLayerRange prevents sroute from using TOP_M to connect IO pad power pins
setSrouteMode \
    -padPinLayerRange {M1 M5} \
    -padPinTarget nearestTarget
sroute \
    -connect { corePin padRing } \
    -layerChangeRange { M1 M5 } \
    -blockPinTarget { nearestTarget } \
    -padPinPortConnect { allPort } \
    -nets { VDD VSS }

puts "=== STEP 6: Routing blockages — keep signals out of pad ring area ==="
# Prevent signal router from using M3-M5 inside the 75um pad ring margins
createRouteBlk -layer {M3 M4 M5} \
    -box 0 0 1799.84 75.04 -name blk_bot
createRouteBlk -layer {M3 M4 M5} \
    -box 0 1724.80 1799.84 1799.84 -name blk_top
createRouteBlk -layer {M3 M4 M5} \
    -box 0 0 75.60 1799.84 -name blk_left
createRouteBlk -layer {M3 M4 M5} \
    -box 1724.24 0 1799.84 1799.84 -name blk_right

puts "=== Floorplan + Power Planning DONE ==="
puts "Next: placeDesign, source cts.tcl, then routeDesign"
