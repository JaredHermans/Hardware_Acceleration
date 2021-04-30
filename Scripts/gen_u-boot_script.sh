#!/bin/bash
# JARED HERMANS
../Quartus_Project/software/spl_bsp/u-boot-socfpga/tools/mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "My script" -d u-boot.txt u-boot.scr
