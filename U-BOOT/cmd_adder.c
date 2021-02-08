#include <common.h>
#include <command.h>
//#include "inttypes.h"
#include "../../../../qsys_headers/hps_0.h"
#include "../../../../qsys_headers/QSYS.h"
#include "socal/socal.h"
#include "alt_bridge_manager.h"
//#include "alt_hps_detect.h"
#include "alt_address_space.h"
#include "alt_bridge_manager.c"

//ALT_DEVICE_FAMILY = soc_cv_av

ALT_STATUS_CODE socfpga_bridge_setup(ALT_BRIDGE_t bridge)
{
	ALT_STATUS_CODE status = ALT_E_SUCCESS;
/*
	if (!alt_hps_detect_is_cyclone5())
	{
		printf("ERROR: Code is specific to Cycone 5 SoCFPGA.\n");
	}*/

	printf("INFO: Setup Bridge [%d]...\n", bridge);

	if (status == ALT_E_SUCCESS)
	{
		status = alt_bridge_init(bridge,NULL,NULL);
	}
/*
	if (status == ALT_E_SUCCESS)
	{
		status = alt_addr_space_remap(ALT_ADDR_SPACE_MPU_ZERO_AT_BOOTROM,
									  ALT_ADDR_SPACE_NONMPU_ZERO_AT_OCRAM,
									  ALT_ADDR_SPACE_H2F_ACCESSIBLE,
									  ALT_ADDR_SPACE_LWH2F_ACCESSIBLE);
	}*/

	if (status == ALT_E_SUCCESS)
	{
		printf("INFO: Setup of Bridge [%d] successful. \n\n", bridge);
	}
	else
	{
		printf("ERROR: Setup of Bridge [%d] failed. [status = %d].\n\n",bridge,status);
	}

	return status;
}

ALT_STATUS_CODE socfpga_bridge_io(void)
{
	/*
	Unit of Memory | Abbreviation | Size in Bits
 * :---------------|:-------------|:------------:
 *  Byte           | byte         |       8
 *  Half Word      | hword        |      16
 *  Word           | word         |      32
 *  Double Word    | dword        |      64
 */
	alt_write_word(X_Y_DATA_BASE,0xDDDD1111);

	int result_0 = alt_read_hword(Z_DATA_BASE);

	printf("FPGA Adder: DDDD + 1111 = %d\n", result_0);

	return ALT_E_SUCCESS;
}

void socfpga_bridge_cleanup(ALT_BRIDGE_t bridge)
{
	printf("INFO: Cleanup of Bridge [%d] ... \n", bridge);

	if (alt_bridge_uninit(bridge, NULL, NULL) != ALT_E_SUCCESS)
	{
		printf("WARN: alt_bridge_uninit() returned non-SUCCESS.\n");
	}
}

static int do_adder(cmd_tbl_t *cmdtp, int flag, int argc, char * const argv[])
{
	printf("Beginning of custom U-BOOT command adder\n\n");
	printf("Beginning of FPGA adder\n");
	ALT_STATUS_CODE status = ALT_E_SUCCESS;
	if (status == ALT_E_SUCCESS)
	{
		status = socfpga_bridge_setup(ALT_BRIDGE_LWH2F);
	}

	if (status == ALT_E_SUCCESS)
	{
		status = socfpga_bridge_io();
	}

	socfpga_bridge_cleanup(ALT_BRIDGE_LWH2F);

	if (status == ALT_E_SUCCESS)
	{
		printf("RESULT: Example completed successfully. \n");
	}
	else 
	{
		printf("RESULT: Some failures detected.\n");
	}
	
	
	printf("Beginning of HPS Adder\n");
	int dataa = 61166, datab = 4369, result_hps;
	printf("First 16-bit number in hex: EEEE\n");
	printf("Second 16-bit number in hex: 1111\n");
	printf("Adding 2 numbers: \n");
	result_hps = dataa + datab;
	printf("%d + %d = %d\n", dataa, datab, result_hps);
	//printf("FPGA Adder: DDDD + 1111 = %d\n",result_0);
	return(0);
}
U_BOOT_CMD(adder, CONFIG_SYS_MAXARGS, 1, do_adder, "Add 2 16-bit numbers",
		"[args..]\n"
		" 	- echo args to console; \\c suppresses newline"
	  );
