Development of U-BOOT is similar to Linux. Stock commands can be seen in the U-BOOT environment by typing help. Here custom U-BOOT commands are made to 
perform an action. The following explains how to create a custom hello world U-BOOT command called hello.

## Steps to make a Custom U-BOOT Command: ##
* U-BOOT commands begin with cmd. Copy cmd_hello.c to <quartus_project_dir>/software/spl_bsp/uboot-socfpga/common
* Edit the Makefile in uboot-socfpga/common to include cmd_hello.c into the compiled project:
      Add line COBJS-$(CONFIG_CMD_HELLO) += cmd_hello.o
* Edit header file in uboot-socfpga/include/config_cmd_all.h :
      Add line #define CONFIG_CMD_HELLO
* Edit header file in uboot-socfpga/include/config_cmd_default.h :
      Add line #define CONFIG_CMD_HELLO
      
Go to <quartus_project_dir>/software/spl_bsp and run "make clean" followed by "make uboot"
