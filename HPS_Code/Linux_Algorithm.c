#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h> // Provides the mmap and munmap functions
#include <math.h>
#include <unistd.h>

#define FPGA_AXI_BASE  	 0xC0000000
#define HW_REGS_SPAN     0x00200000
#define HW_REGS_MASK	 (HW_REGS_SPAN - 1)

#define ACLR_BASE        0x10           // from hps_0.h
#define DONE_BASE        0x20
#define XY_DATAA_BASE    0x30
#define XY_DATAB_BASE    0x40
#define XX_DATAA_BASE    0x50
#define XX_DATAB_BASE    0x60
#define YY_DATAA_BASE    0x70
#define YY_DATAB_BASE    0x80
#define FPGA_TIME_BASE   0x90
#define FULL_TIME_BASE   0xA0
#define UART_BASE        0xb0

typedef struct {
	__uint64_t lo;
	__uint64_t hi;
} uint128_t;

// Main AXI Bus:
void *virtual_base;

volatile __uint8_t *aclr = NULL;
volatile __uint8_t *HPS_Done = NULL;
volatile __uint32_t *xy_Dataa = NULL;
volatile __uint32_t *xy_Datab = NULL;
volatile __uint32_t *xx_Dataa = NULL;
volatile __uint32_t *xx_Datab = NULL;
volatile __uint32_t *yy_Dataa = NULL;
volatile __uint32_t *yy_Datab = NULL;
volatile __uint32_t *FPGA_Time = NULL;
volatile __uint32_t *FULL_Time = NULL;
volatile __uint8_t *UART = NULL;

__uint64_t LSB(__uint64_t input)
{
        return(input & 0x00000000FFFFFFFF);
}

__uint64_t MSB(__uint64_t input)
{
        return(input & 0xFFFFFFFF00000000);
}

// 32-bit multiplication between 2 64-bit numbers. Result is 128 bits. 
void MULT(__uint64_t x, __uint64_t y, __uint64_t* res1, __uint64_t* res2)
{
    __uint64_t xLow, yLow, xHigh, yHigh;
    __uint64_t xLow_yLow, xHigh_yLow, xLow_yHigh, xHigh_yHigh;

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

__uint32_t sqrt_64(__uint64_t input)
{
	__uint32_t root = 0;
	__uint32_t Bit;

	for (Bit = 0x80000000L; Bit > 0; Bit >>= 1)
	{
		__uint32_t trial = root + Bit;
		if((__uint64_t)trial * (__uint64_t)trial < input)
			root += Bit;
	}
	return root;
}

int main(void)
{
	//FILE *out;
	int fd;
	__uint32_t mult_time, sq_time, sq2_time, sq_lo2, sq_hi2;
	__uint64_t xx_Data, xy_Data, yy_Data;
	uint128_t MULT_res;
	long double sq_lo, sq_hi;

	// Open /dev/mem
	if( (fd = open( "/dev/mem", (O_RDWR | O_SYNC ) ) ) == -1 )
	{
		printf("ERROR: could not open \"dev/mem\"...\n");
		return(1);
	}

	// Get virtual addr that maps to physical
	virtual_base = mmap(NULL, HW_REGS_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, FPGA_AXI_BASE);
	if (virtual_base == MAP_FAILED)
	{
		printf("ERROR: mmap() failed ...\n");
		close(fd);
		return(1);
	}

	// Get the addresses that map to the parallel ports on AXI Master bus
	aclr = (__uint8_t *)(virtual_base + ACLR_BASE); 			// Output

	xy_Dataa = (__uint32_t *)(virtual_base + XY_DATAA_BASE); 	// Input
	xy_Datab = (__uint32_t *)(virtual_base + XY_DATAB_BASE); 	// Input
	xx_Dataa = (__uint32_t *)(virtual_base + XX_DATAA_BASE); 	// Input
	xx_Datab = (__uint32_t *)(virtual_base + XX_DATAB_BASE); 	// Input
	yy_Dataa = (__uint32_t *)(virtual_base + YY_DATAA_BASE); 	// Input
	yy_Datab = (__uint32_t *)(virtual_base + YY_DATAB_BASE); 	// Input
	FPGA_Time= (__uint32_t *)(virtual_base + FPGA_TIME_BASE); 	// Input
	FULL_Time= (__uint32_t *)(virtual_base + FULL_TIME_BASE); 	// Input
	UART 	 = (__uint8_t *)(virtual_base + UART_BASE); 		// Output
	HPS_Done = (__uint8_t *)(virtual_base + DONE_BASE); 		// Output

	while(1)
	{
		// Reset board:
		printf("Resetting FPGA:\n");
		*(aclr) = 1;					// Timer in FPGA starts

		xy_Data = *xy_Dataa | (((__uint64_t) *xy_Datab) << 32);
		xx_Data = *xx_Dataa | (((__uint64_t) *xx_Datab) << 32);
		yy_Data = *yy_Dataa | (((__uint64_t) *yy_Datab) << 32);

		MULT(xx_Data, yy_Data, &MULT_res.lo, &MULT_res.hi);

		*HPS_Done = 1;					// Timer in FPGA stops
		mult_time = *FULL_Time;
		*HPS_Done = 0; 					// Resume Timer

		sq_lo = sqrt(MULT_res.lo);
		sq_hi = sqrt(MULT_res.hi);

		*HPS_Done = 1; 					// Stop Timer
		sq_time = *FULL_Time;
		*HPS_Done = 0;

		sq_lo2 = sqrt_64(MULT_res.lo);
		sq_hi2 = sqrt_64(MULT_res.hi);

		*HPS_Done = 1;
		sq2_time = *FULL_Time;
		
		printf("xy_Data = %.16llX\n", xy_Data);
		printf("xx_Data = %.16llX\n", xx_Data);
		printf("yy_Data = %.16llX\n\n", yy_Data);

		printf("%.16llX * %.16llX = %.16llX%.16llX\n\n", xx_Data, yy_Data, MULT_res.hi, MULT_res.lo);
	
		printf("Square root of %.16llX = %.8lA\n", MULT_res.hi, sq_hi);
		printf("Square root of %.16llX = %.8lA\n\n", MULT_res.lo, sq_lo);

		printf("Square root of %.16llX = %.8lX\n", MULT_res.hi, sq_hi2);
		printf("Square root of %.16llX = %.8lX\n\n", MULT_res.lo, sq_lo2);

		printf("FPGA_Time = %d Clock Cycles\n", *FPGA_Time);
		printf("Multiplication Time = %d Clock Cycles\n", mult_time);
		printf("Square Root Time = %d\n", sq_time);
		printf("Square Root 2 Time = %d\n\n", sq2_time);

		printf("Testing Bluetooth:\n\n");
		// Test values
		*UART = 0x30; // 0
		*UART = 0x2E; // .
		*UART = 0x39; // 9
		*UART = 0x34; // 4
		*UART = 0x2C; // ,
		*UART = 0x30; // 0
		*UART = 0x2E; // .
		*UART = 0x31; // 1
		*UART = 0x33; // 3
		*UART = 0x0A; // Line Feed
		*UART = 0x0D; // Horizontal Tab

		*aclr = 0;
		return(0);
	}

	close(fd);
	return(0);
}

// 68cdb77922a4f2a8c = 120830302097125616268
