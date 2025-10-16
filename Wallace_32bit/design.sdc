#ock (adjust period to your target)
create_clock -name clk -period 8 [get_ports clk]

# Optional: set input delays (example 1ns)
set_input_delay 1.0 -clock clk [all_inputs]

# Optional: set output delays (example 1ns)
set_output_delay 1.0 -clock clk [all_outputs]

# You can also constrain false paths if needed

