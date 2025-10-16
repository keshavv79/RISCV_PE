# =====================================================
# Top Module Name
# =====================================================
set ::env(DESIGN_NAME) booth_wallace_multiplier_seq

# =====================================================
# RTL Source Files (include all Verilog in src/)
# =====================================================
set ::env(VERILOG_FILES) "\
    $::env(DESIGN_DIR)/src/booth_encoder.v \
    $::env(DESIGN_DIR)/src/pp_generator.v \
    $::env(DESIGN_DIR)/src/wallace_tree.v \
    $::env(DESIGN_DIR)/src/CSA.v \
    $::env(DESIGN_DIR)/src/FA.v \
    $::env(DESIGN_DIR)/src/top.v \
    $::env(DESIGN_DIR)/src/CLA.v \
    $::env(DESIGN_DIR)/src/booth_wallace_mult_combinational.v" 
set ::env(SYNTH_STRATEGY) "DELAY 1"
set ::env(SYNTH_ADDER_TYPE) "YOSYS"
set ::env(SYNTH_RETIME) 1

# =====================================================
# Clock & Reset
# =====================================================
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "8"   ;# 100 MHz target
set ::env(RESET_PORT) "rst"      ;# if you have reset in RTL

# =====================================================
# Floorplan Settings
# =====================================================
set ::env(DIE_AREA)  "0 0 2000 2000"
set ::env(CORE_AREA) "10 10 1990 1990"

# =====================================================
# Power/Ground Nets
# =====================================================
set ::env(VDD_PIN) "vccd1"
set ::env(GND_PIN) "vssd1"
set ::env(PNR_SDC_FILE) "$::env(DESIGN_DIR)/src/design.sdc"
set ::env(SIGNOFF_SDC_FILE) "$::env(DESIGN_DIR)/src/design.sdc"

# =====================================================
# Flow Control (enable full flow including power)
# =====================================================
set ::env(RUN_SYNTH)        1
set ::env(RUN_FLOORPLAN)    1
set ::env(RUN_PLACEMENT)    1
set ::env(RUN_CTS)          1
set ::env(RUN_ROUTING)      1
set ::env(RUN_POWER)        1   ;# 🔑 this enables power analysis
set ::env(RUN_REPORTS)      1   ;# timing + power reports
set ::env(RUN_STREAM_OUT)   1
# Enable power analysis in signoff
set ::env(RUN_POWER) 1

# Enable power report after synthesis too (optional)
set ::env(SYNTH_POWER) 1

