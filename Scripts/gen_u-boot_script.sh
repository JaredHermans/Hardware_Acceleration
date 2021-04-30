#!/bin/bash
# JARED HERMANS

# Run Intel EDS 2020.1
../Quartus_Project/software/spl_bsp/u-boot-socfpga/tools/mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "My script" -d u-boot.txt u-boot.scr
