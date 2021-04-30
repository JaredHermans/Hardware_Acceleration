#!/bin/bash
# Jared Hermans

cp ../C_CODE/socfpga.c ../Quartus_Project/software/spl_bsp/u-boot-socfpga/board/altera/cyclone5-socdk
cd ../Quartus_Project/software/spl_bsp/u-boot-socfpga
make socfpga_cyclone5_defconfig
make -j 24
cd ../../../Scripts
