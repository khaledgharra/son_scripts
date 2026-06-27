#============================================================
# I2C Master synthesis script for LEC
# Same as i2c_syn.tcl but with set_vsdc to record transformations
# Run this FIRST before running LEC dofile
#============================================================

remove_design -all

set DESIGN_NAME i2c_master_top
set CLK_NAME    wb_clk_i
set CLK_PERIOD  10

set_app_var search_path [concat [list . [pwd]] $search_path]

file mkdir WORK
define_design_lib WORK -path ./WORK

analyze -format sverilog {
    ../i2c_syn_tech/i2c_master_bit_ctrl.sv
    ../i2c_syn_tech/i2c_master_byte_ctrl.sv
    ../i2c_syn_tech/i2c_master_top.sv
}

elaborate $DESIGN_NAME
current_design $DESIGN_NAME
link
uniquify
check_design

create_clock -name $CLK_NAME -period $CLK_PERIOD \
    -waveform [list 0 [expr {$CLK_PERIOD / 2.0}]] [get_ports $CLK_NAME]
set_input_delay  0 -clock $CLK_NAME \
    [remove_from_collection [all_inputs] [get_ports $CLK_NAME]]
set_output_delay 0 -clock $CLK_NAME [all_outputs]

set compile_seqmap_propagate_constants false

set_vsdc compile.vsdc

compile -exact_map

write -hierarchy -format verilog -output i2c_master_top_syn_lec.v

puts "============================================================"
puts "LEC synthesis done. Files generated:"
puts "  i2c_master_top_syn_lec.v"
puts "  compile.vsdc"
puts "============================================================"
