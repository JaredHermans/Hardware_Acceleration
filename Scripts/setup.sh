#!/bin/bash
# JARED HERMANS

# copy to <quartus prj directory>/MY_CODE
bsp-create-settings \
	--type spl \
	--bsp-dir ../Quartus_Project/software/spl_bsp \
	--preloader-settings-dir "../Quartus_Project/hps_isw_handoff/QSYS_hps_0/" \
	--settings ../Quartus_Project/software/spl_bsp/settings.bsp
cd ../Quartus_Project/software/spl_bsp
wget https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/\
gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf.tar.xz
tar xf gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf.tar.xz
rm gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf.tar.xz
export PATH=`pwd`/gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf/bin:$PATH
git clone https://github.com/altera-opensource/u-boot-socfpga
cd u-boot-socfpga
git checkout -b test-bootloader -t origin/socfpga_v2020.07
./arch/arm/mach-socfpga/qts-filter.sh cyclone5 ../../../ ../ ./board/altera/cyclone5-socdk/qts/
cd ..
export CROSS_COMPILE=arm-none-linux-gnueabihf-
cd ../../../Scripts
