create_clock -name clk_pad  -period 20.0 [get_ports clk_pad]
create_clock -name clk_core -period 20.0 [get_pins pad_clk/IN]
set_input_delay  4.0 -clock [get_clocks clk_pad] [all_inputs]
set_output_delay 4.0 -clock [get_clocks clk_pad] [all_outputs]
