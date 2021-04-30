#!/bin/bash
# JARED HERMANS

# copy to <quartus prj directory>/MY_CODE/U_BOOT
cp ../socfpga.c ../../software2/spl_bsp/uboot-socfpga/common/cmd_ddr.c
cd ../../software2/spl_bsp
make clean
make
make uboot
