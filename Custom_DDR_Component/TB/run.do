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

add wave -position insertpoint  \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/r_State \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/r_current_state \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/w_Command_Status_Regs \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/Internal_Address \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/Base_Address \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/Data_Counter \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/Control_Avalon_MM_Address \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/Control_Avalon_MM_Write \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/Control_Avalon_MM_WriteData \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/SDRAM_Avalon_MM_Address_cld \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/SDRAM_Avalon_MM_WaitReq \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/SDRAM_Avalon_MM_ReadData \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/SDRAM_Avalon_MM_Read_DV \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/SDRAM_Avalon_MM_Address \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/SDRAM_Avalon_MM_BE \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/SDRAM_Avalon_MM_Read \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/FIFO_Data \
sim:/ddr_tb/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/FIFO_Write_EN



view structure
view signals
run -all