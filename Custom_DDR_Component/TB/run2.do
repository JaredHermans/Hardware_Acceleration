transcript on
if ![file isdirectory DDR_iputf_libs] {
	file mkdir DDR_iputf_libs
}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom "/tools/intelFPGA_lite/20.1/ip/Custom_IP/Custom_DDR_Component/Source/DDR3_Read_Top.vhd"

#vlog -vlog01compat -work work +incdir+/media/jared/56A8-C420/FPGA_Projects/New_Altera_FPGA_Projects/MULT_IP_Test/FIFO_MULT5/db {/media/jared/56A8-C420/FPGA_Projects/New_Altera_FPGA_Projects/MULT_IP_Test/FIFO_MULT5/db/altera_mult_add_imtg.v}
vcom -93 -work work {/tools/intelFPGA_lite/20.1/ip/Custom_IP/Custom_DDR_Component/Source/FIFO_IP.vhd}
vcom -93 -work work {/tools/intelFPGA_lite/20.1/ip/Custom_IP/Custom_DDR_Component/Source/SDRAM_CTRL.vhd}

vcom -93 -work work {/tools/intelFPGA_lite/20.1/ip/Custom_IP/Custom_DDR_Component/TB_VHDL/DDR_TB.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="+acc"  DDR_TB

add wave *
view structure
view signals
run -all