#!/bin/bash
# JARED HERMANS

# Run Intel EDS 2016
../../Quartus_Project/software2/spl_bsp/uboot-socfpga/tools/mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "My script" -d u-boot.txt u-boot.scr
