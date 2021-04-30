#!/bin/bash
# JARED HERMANS

# Run Intel EDS 2016
cp ../../C_Code/U-Boot/socfpga.c ../../software2/spl_bsp/uboot-socfpga/common/cmd_ddr.c
cd ../../software2/spl_bsp
make clean
make
make uboot
