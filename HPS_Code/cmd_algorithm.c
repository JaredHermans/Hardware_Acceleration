// Custom U-Boot Command -- work in progress

#include <common.h>
#include <command.h>
#include "../../../../qsys_headers/hps_0.h"
#include "../../../../qsys_headers/QSYS.h"

#define FPGA_AXI_BASE 0xC0000000 // AXI Master address

// ACLR_BASE 0x10           // from hps_0.h
// DONE_BASE 0x20
// XY_DATAA_BASE 0x30
// XY_DATAB_BASE 0x40
// XX_DATAA_BASE 0x50
// XX_DATAB_BASE 0x60
// YY_DATAA_BASE 0x70
// YY_DATAB_BASE 0x80

double sqrtx(uint64_t res1, uint64_t res2)
{
        double temp, ans;
        temp = 0;
        ans = res1 / 2;
        while(ans != temp)
        {
            temp = ans;
            ans = ( res1/temp + temp) / 2;
        }
        printf("INSIDE FUNCTION: The square root of %.16llX is '%.16llX'\n\n", res1, (uint64_t) ans);
        return(ans);
}

uint64_t LSB(uint64_t input)
{
        return(input & 0x00000000FFFFFFFF);
}

uint64_t MSB(uint64_t input)
{
        return(input & 0xFFFFFFFF00000000);
}

// 32-bit multiplication between 2 64-bit numbers. Result is 128 bits. 
void MULT(uint64_t x, uint64_t y, uint64_t* res1, uint64_t* res2)
{
    uint64_t xLow, yLow, xHigh, yHigh;
    uint64_t xLow_yLow, xHigh_yLow, xLow_yHigh, xHigh_yHigh;

    xLow = LSB(x);
    yLow = LSB(y);
    xHigh = MSB(x) >> 32;
    yHigh = MSB(y) >> 32;

    xLow_yLow = xLow * yLow;
    xHigh_yLow = xHigh * yLow;
    xLow_yHigh = xLow * yHigh;
    xHigh_yHigh = xHigh * yHigh;

    *res1 = xLow_yLow + ((LSB(xHigh_yLow + xLow_yHigh)) << 32);
    *res2 = xHigh_yHigh + ((MSB(xHigh_yLow + xLow_yHigh)) >> 32);
}

static int do_algorithm(cmd_tbl_t *cmdtp, int flag, int argc, char * const argv[])
{
    uint64_t cor_xx = 0x246E6F85E, cor_yy = 0x2E071EF9A, cor_xy = 0x1FDEFC3C4;
    uint64_t xx_Data, yy_Data, xy_Data, res1, res2;
    double sq1, sq2, sq3, sq4, sq5, ANS;

    printf("\nStarting Custom U-BOOT Command:\n");

    writel(0x00000001, FPGA_AXI_BASE + ACLR_BASE);   // Initial Reset
    writel(0x00000000, FPGA_AXI_BASE + ACLR_BASE);

    printf("Initial Reset Complete\n");

    xy_Data = readl(FPGA_AXI_BASE + XY_DATAA_BASE) | (((uint64_t) readl(FPGA_AXI_BASE + XY_DATAB_BASE)) << 32);
    xx_Data = readl(FPGA_AXI_BASE + XX_DATAA_BASE) | (((uint64_t) readl(FPGA_AXI_BASE + XX_DATAB_BASE)) << 32);
    yy_Data = readl(FPGA_AXI_BASE + YY_DATAA_BASE) | (((uint64_t) readl(FPGA_AXI_BASE + YY_DATAB_BASE)) << 32);

    printf("\nxy_Data = %.16llX - Correct Value = %llX\n", xy_Data, cor_xy);
    printf("xx_Data = %.16llX - Correct Value = %llX\n", xx_Data, cor_xx);
    printf("yy_Data = %.16llX - Correct Value = %llX\n", yy_Data, cor_yy);

    MULT(xx_Data, yy_Data, &res1, &res2);

    printf("\nxx_Data * yy_Data = %.16llX%.16llX\n\n", res2, res1);

    printf("Starting Square root: \n\n");

    sq1 = sqrtx(res1,res2);
    sq2 = sqrtx(res2, res1);

    printf("The square root of %.16llX is %.16llX\n", res1, (uint64_t) sq1);
    printf("The square root of %.16llX is %.16llX\n\n", res2, (uint64_t) sq2);

    printf("Calculated answer: Square root is %.16llX\n", sq1 * sq2);

    printf("Correct answer: Square root of 68CDB77922A4F2A8C is A3CC3C1A\n\n");
    uint64_t res3 = 0xFFFFFFFFFFFFFFFF, res4 = 0x0434334311901190, res5 = 0x88ff88ffff88ff88;
    sq3 = sqrtx(res3, res2);
    printf("The square root of %.16llX is %.16llX\n", res3, (uint64_t) sq3);
    sq4 = sqrtx(res4, res2);
    printf("The square root of %.16llX is %.16llX\n", res4, (uint64_t) sq4);
    sq5 = sqrtx(res5, res2);
    printf("Thes square root of %.16llX is %.16llX\n\n", res5, (uint64_t) sq5);

    //Result = __builtin_sqrt(xx_Dataa);
    
    return(0);
}
U_BOOT_CMD(algorithm, CONFIG_SYS_MAXARGS, 1, do_algorithm, "Calculate Algorithm",
		"[args..]\n"
		" 	- echo args to console; \\c suppresses newline"
	  );
      
