#include <stdio.h>

int main()
{
	FILE *fd;
	int addr = 0x30000000;

	fd = fopen("u-boot.txt", "w+");
	fprintf(fd, "echo --Disabling Cache--\n");
	fprintf(fd, "dcache off\n");
	fprintf(fd, "echo --Programming FPGA--\n");
	fprintf(fd, "fatload mmc 0:1 0x2000000 novpekcvlite.rbf\n");
	fprintf(fd, "fpga load 0 0x2000000 ${filesize}\n");
	fprintf(fd, "bridge enable\n");
	for(int i = 0; i < 259200; i++) {
		fprintf(fd, "mw 0x%x 0x31a17bdd\n", addr);
		fprintf(fd, "mw 0x%x 0xfc178b52\n", addr + 0x4);
		fprintf(fd, "mw 0x%x 0x58f6d156\n", addr + 0x8);
		fprintf(fd, "mw 0x%x 0x59a7026a\n", addr + 0xC);
		fprintf(fd, "mw 0x%x 0x9ac356af\n", addr + 0x10);
		fprintf(fd, "mw 0x%x 0x2fa77956\n", addr + 0x14);
		fprintf(fd, "mw 0x%x 0xeaec95cd\n", addr + 0x18);
		fprintf(fd, "mw 0x%x 0x91b8ace2\n", addr + 0x1C);
		addr = addr + 0x20;
	}
	return(0);
}
