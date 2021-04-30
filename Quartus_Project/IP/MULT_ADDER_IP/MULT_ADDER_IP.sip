set_global_assignment -entity "MULT_ADDER_IP" -library "lib_MULT_ADDER_IP" -name IP_TOOL_NAME "altera_mult_add"
set_global_assignment -entity "MULT_ADDER_IP" -library "lib_MULT_ADDER_IP" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "MULT_ADDER_IP" -library "lib_MULT_ADDER_IP" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_MULT_ADDER_IP" -name SPD_FILE [file join $::quartus(sip_path) "MULT_ADDER_IP.spd"]

set_global_assignment -library "lib_MULT_ADDER_IP" -name MISC_FILE [file join $::quartus(sip_path) "MULT_ADDER_IP_sim/MULT_ADDER_IP.vhd"]
