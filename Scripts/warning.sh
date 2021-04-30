#!/bin/bash
# JARED HERMANS

# copy to <quartus prj directory/software/spl-bsp/u-boot-socfpga
cd ../software/spl_bsp/u-boot-socfpga
sudo dd if=u-boot-with-spl.sfp of=/dev/sdc2
sync
sudo umount /media/jared/BOOT
cd ../../../C_CODE
