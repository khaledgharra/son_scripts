#============================================================
# I2C Master DFT Script - Scan Insertion
# Tool       : Synopsys Design Compiler / Design Vision
# Top module : i2c_master_top
# Run after  : syn.tcl (design must be compiled and in memory)
# Output     : i2c_master_top_dft.v
#              i2c_master_top.scandef
#============================================================

# If running standalone (not after syn.tcl), uncomment below:
# source ../i2c_syn_tech/i2c_syn.tcl

puts "============================================================"
puts "Starting DFT - Scan Insertion"
puts "============================================================"

#------------------------------------------------------------
# 1. Define test signals on existing design ports
#------------------------------------------------------------

# Clock for scan shift
set_dft_signal -view existing_dft \
    -type ScanClock \
    -port wb_clk_i \
    -timing {45 55}

set_dft_signal -view spec \
    -type ScanClock \
    -port wb_clk_i

# Synchronous reset (active high)
set_dft_signal -view existing_dft \
    -type Reset \
    -active_state 1 \
    -port wb_rst_i

set_dft_signal -view spec \
    -type Reset \
    -active_state 1 \
    -port wb_rst_i

# Asynchronous reset (active low)
set_dft_signal -view existing_dft \
    -type Reset \
    -active_state 0 \
    -port arst_i

set_dft_signal -view spec \
    -type Reset \
    -active_state 0 \
    -port arst_i

# Scan Enable
create_port -direction in test_se
set_dft_signal -view existing_dft \
    -type ScanEnable \
    -active_state 1 \
    -port test_se
set_dft_signal -view spec \
    -type ScanEnable \
    -active_state 1 \
    -port test_se

#------------------------------------------------------------
# 2. Scan chain configuration - 5 chains (matches floorplan)
#------------------------------------------------------------

set_scan_configuration \
    -chain_count 5 \
    -style multiplexed_flip_flop \
    -clock_mixing no_mix

#------------------------------------------------------------
# 3. DRC check before insertion
#------------------------------------------------------------

puts "--- DFT DRC pre-insertion ---"
dft_drc

#------------------------------------------------------------
# 4. Preview scan chains
#------------------------------------------------------------

puts "--- Create test protocol ---"
create_test_protocol -infer_asynch

puts "--- Preview DFT ---"
preview_dft -show all

#------------------------------------------------------------
# 5. Insert scan
#------------------------------------------------------------

puts "--- Inserting scan ---"
insert_dft

#------------------------------------------------------------
# 6. DRC check after insertion
#------------------------------------------------------------

puts "--- DFT DRC post-insertion ---"
dft_drc

#------------------------------------------------------------
# 7. Reports
#------------------------------------------------------------

file mkdir reports
redirect -file reports/dft_drc.rpt     { dft_drc }
redirect -file reports/scan_chains.rpt { report_scan_chains }
redirect -file reports/scan_path.rpt   { report_scan_path }
redirect -file reports/timing_dft.rpt  { report_timing -max_paths 10 }

#------------------------------------------------------------
# 8. Write outputs
#------------------------------------------------------------

# Scan-inserted netlist
write -hierarchy -format verilog -output i2c_master_top_dft.v

# Scan DEF for Innovus
write_scan_def -output i2c_master_top.scandef

puts "============================================================"
puts "DFT FINISHED SUCCESSFULLY"
puts "Scan-inserted netlist : i2c_master_top_dft.v"
puts "Scan DEF for Innovus  : i2c_master_top.scandef"
puts "Reports               : reports/dft_drc.rpt"
puts "                        reports/scan_chains.rpt"
puts "============================================================"
