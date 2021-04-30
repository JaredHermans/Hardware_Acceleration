cd ../../software2/spl_bsp
sudo dd if=preloader-mkpimage.bin of=/dev/sdc2
cd uboot-socfpga
sudo dd if=u-boot.img of=/dev/sdc2 bs=1k seek=256 conv=fsync
cd ../../../C_CODE/U-BOOT2
umount /media/jared/BOOT
