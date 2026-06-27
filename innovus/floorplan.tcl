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
# TOP_M top/bottom (horizontal), M5 left/right (vertical)
setAddRingMode \
    -ring_target default \
    -extend_over_row 0 \
    -ignore_rows 0 \
    -avoid_short 0 \
    -skip_crossing_trunks none \
    -stacked_via_top_layer TOP_M \
    -stacked_via_bottom_layer M1 \
    -orthogonal_only true \
    -skip_via_on_pin { standardcell } \
    -skip_via_on_wire_shape { noshape }

addRing \
    -nets {VDD VSS} \
    -around default_power_domain \
    -layer {top TOP_M bottom TOP_M left M5 right M5} \
    -width 6 \
    -spacing 1.8 \
    -center 1 \
    -jog_distance 0.56 \
    -threshold 0.56

puts "=== STEP 4: Add vertical power stripes (M5) ==="
# ybottom/ytop_offset keeps stripes inside core boundary (avoids pad cell blockages)
addStripe \
    -nets {VDD VSS} \
    -layer M5 \
    -direction vertical \
    -width 6 \
    -spacing 1.8 \
    -set_to_set_distance 100 \
    -start_from left \
    -stacked_via_top_layer TOP_M \
    -stacked_via_bottom_layer M1 \
    -ybottom_offset 75.04 \
    -ytop_offset 75.04

puts "=== STEP 5: Route power to standard cell pins ==="
setSrouteMode \
    -padPinLayerRange {M1 TOP_M} \
    -padPinTarget nearestTarget
sroute \
    -connect { corePin padRing } \
    -layerChangeRange { M1 TOP_M } \
    -blockPinTarget { nearestTarget } \
    -padPinPortConnect { allPort } \
    -nets { VDD VSS }

puts "=== STEP 6: Routing blockages — keep signals out of pad ring area ==="
# Prevent signal router from using M3-TOP_M inside the 75um pad ring margins
createRouteBlk -layer {M3 M4 M5 TOP_M} \
    -box 0 0 1799.84 75.04 -name blk_bot
createRouteBlk -layer {M3 M4 M5 TOP_M} \
    -box 0 1724.80 1799.84 1799.84 -name blk_top
createRouteBlk -layer {M3 M4 M5 TOP_M} \
    -box 0 0 75.60 1799.84 -name blk_left
createRouteBlk -layer {M3 M4 M5 TOP_M} \
    -box 1724.24 0 1799.84 1799.84 -name blk_right

puts "=== STEP 7: Placement blockages M3-TOP_M — keep cells out of pad ring area ==="
createPlaceBlockage -type hard -layer {M3 M4 M5 TOP_M} \
    -box 0 0 1799.84 75.04 -name plcblk_bot
createPlaceBlockage -type hard -layer {M3 M4 M5 TOP_M} \
    -box 0 1724.80 1799.84 1799.84 -name plcblk_top
createPlaceBlockage -type hard -layer {M3 M4 M5 TOP_M} \
    -box 0 0 75.60 1799.84 -name plcblk_left
createPlaceBlockage -type hard -layer {M3 M4 M5 TOP_M} \
    -box 1724.24 0 1799.84 1799.84 -name plcblk_right

puts "=== Floorplan + Power Planning DONE ==="
puts "Next: placeDesign (setPlaceMode -maxDensity 0.3), source cts.tcl, then routeDesign"
