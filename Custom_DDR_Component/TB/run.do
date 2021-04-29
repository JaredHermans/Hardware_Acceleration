transcript on
if ![file isdirectory DDR_iputf_libs] {
	file mkdir DDR_iputf_libs
}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom "../Source/DDR3_Read_Top.vhd"

vcom -93 -work work {../Source/FIFO_IP.vhd}
vcom -93 -work work {../Source/SDRAM_CTRL.vhd}

vcom -93 -work work {../TB_VHDL/DDR_TB2.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="+acc"  DDR_TB2

add wave *
add wave -position insertpoint  \
sim:/ddr_tb2/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/r_State \
sim:/ddr_tb2/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/r_current_state \
sim:/ddr_tb2/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/FIFO_Full \
sim:/ddr_tb2/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/FIFO_Data \
sim:/ddr_tb2/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/FIFO_Write_EN \
sim:/ddr_tb2/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/Data_Counter \
sim:/ddr_tb2/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/r_DDR_Transfer_Done \
sim:/ddr_tb2/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/o_DDR_Transfer_Done \
sim:/ddr_tb2/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/Burst_Counter \
sim:/ddr_tb2/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/Total_Counter \
sim:/ddr_tb2/DDR3_Read_Top_Inst/SDRAM_CTRL_Inst/w_Command_Status_Regs
view structure
view signals
run -all