#!/bin/bash
# JARED HERMANS
../../software2/spl_bsp/uboot-socfpga/tools/mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "My script" -d u-boot.txt u-boot.scr

cp u-boot.scr /media/jared/BOOT
