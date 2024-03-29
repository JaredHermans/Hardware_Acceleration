#!/bin/bash
# JARED HERMANS

# Run Intel EDS 2020.1
sudo cp ../C_CODE/U-BOOT/socfpga.c ../Quartus_Project/software/spl_bsp/u-boot-socfpga/board/altera/cyclone5-socdk/
cd ../Quartus_Project/software/spl_bsp/u-boot-socfpga
cd ..
echo --exporting path--
export PATH=`pwd`/gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf/bin:$PATH
echo --Setting CROSS_COMPILE--
#cd gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf/bin
export CROSS_COMPILE=arm-none-linux-gnueabihf-
cd u-boot-socfpga
make clean
make socfpga_cyclone5_defconfig
make -j 24
cd ../../../Scripts
