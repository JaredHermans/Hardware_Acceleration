#include <common.h>
#include <command.h>

static int do_hello(cmd_tbl_t *cmdtp, int flag, int argc, char * const argv[])
{
	printf("Custom U-BOOT command hello world\n");
}

U_BOOT_CMD(hello, CONFIG_SYS_MAXARGS, 1, do_hello, "Empty for now",
		"[args..]\n"
		" 	- echo args to console; \\c suppresses newline"
	  );
