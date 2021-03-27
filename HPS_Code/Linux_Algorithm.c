#include <stdio.h>
#include <fcntl.h>
#include <sys/mman.h> // Provides the mmap and munmap functions
#include <unistd.h>
//#include <sys/time.h>

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

//struct timeval t1, t2;

typedef struct {
	__uint64_t lo;
	__uint64_t hi;
} uint128_t;

// Main AXI Bus:
void *virtual_base;

// Memmory Mapped Peripherials
__uint8_t  *aclr      = NULL;
__uint8_t  *HPS_Done  = NULL; 		// Output
__uint32_t *xy_Dataa  = NULL;
__uint32_t *xy_Datab  = NULL;
__uint32_t *xx_Dataa  = NULL;
__uint32_t *xx_Datab  = NULL;
__uint32_t *yy_Dataa  = NULL;
__uint32_t *yy_Datab  = NULL;
__uint32_t *FPGA_Time = NULL;
__uint32_t *FULL_Time = NULL;
__uint8_t  *UART      = NULL;		// Output
__uint8_t  *FPGA_Done = NULL;

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

__uint32_t sqrt_64(__uint64_t input)  // Faster square root algorithm than math.h sqrt
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

int intToAscii(int number)
{
    return '0' + number;
}

void Bluetooth(__uint32_t N, __uint8_t size)
{
    __uint32_t r;
    __uint32_t Print = 0;

    Print &= ~0xFFFFFFFFu;
    if (N == 0 && size == 0)
        return;
    // Extract last digit
    r = N % 10;
    // Recursive call to next iteration
    Bluetooth(N / 10, size - 1);

    Print |= intToAscii(r);
	*UART = Print;
	size -= 1;
}

int main(void)
{
	int fd;
	__uint32_t sq_lo, sq_hi; 					// Square root of lower and upper 64 bits of 128 bit number
	__uint32_t Time; 							// Time to complete algorithm in Clock Cycles
	__uint64_t xx_Data, xy_Data, yy_Data, res;
	uint128_t MULT_res;		
	double Final_corr, Bluetooth_Time;			// Final correlation Value and Time in seconds
	//double elapsedTime;

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

	// Reset board:
	printf("\nResetting FPGA:\n\n");

	//gettimeofday(&t1, NULL);

	*(aclr) = 1;											// Timer in FPGA starts and board reset

	xy_Data = *xy_Dataa | (((__uint64_t) *xy_Datab) << 32);
	xx_Data = *xx_Dataa | (((__uint64_t) *xx_Datab) << 32);
	yy_Data = *yy_Dataa | (((__uint64_t) *yy_Datab) << 32);

	MULT(xx_Data, yy_Data, &MULT_res.lo, &MULT_res.hi);		// Ans of xx_Data * yy_Data stored in 2 64-bit integers 

	sq_lo = sqrt_64(MULT_res.lo);							// Lower 64-bits of 128 bit square root
	sq_hi = sqrt_64(MULT_res.hi);							// Upper 64-bits of 128 bit square root

	res = (((__uint64_t) sq_hi) << 32) | (sq_lo);			// 128-bit square root answer
	Final_corr = (double) xy_Data / res;					// Final Correlation Value

	*HPS_Done = 1; 											// Stop FPGA Timer
	Time = *FULL_Time; 										// Read number of clock cycles that have passed from FPGA
	//gettimeofday(&t2, NULL);
	//elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000000.0;
	//elapsedTime += (t2.tv_usec - t1.tv_usec);

	printf("xy_Data = %.16llX\n", xy_Data);
	printf("xx_Data = %.16llX\n", xx_Data);
	printf("yy_Data = %.16llX\n\n", yy_Data);

	printf("%.16llX * %.16llX = %.16llX%.16llX\n\n", xx_Data, yy_Data, MULT_res.hi, MULT_res.lo);
	
	printf("Upper 64-bits square root %.16llX = %.8lX\n", MULT_res.hi, sq_hi);
	printf("Lower 64-bits square root %.16llX = %.8lX\n", MULT_res.lo, sq_lo);

	printf("\nFinal Correlation Value: %f\n", Final_corr);
	printf("Correct Correlation Value: 0.778302\n\n");

	Bluetooth_Time = (double) Time / 50000000;

	printf("Total time for calculation: %d Clock Cycles = %f seconds\n", Time, Bluetooth_Time);
	//printf("Total time for calculation gettimeofday: %f usec\n\n", elapsedTime);

	printf("Testing Bluetooth:\n\n");
	// Test values
	*UART = 0x30; 											// 0
	*UART = 0x2E; 											// .
	Bluetooth((__uint32_t) (Final_corr * 1e9), 9);
	*UART = 0x2C; 											// ,
	*UART = 0x30; 											// 0
	*UART = 0x2E; 											// .
	Bluetooth((__uint32_t) (Bluetooth_Time * 1e9), 9);
	*UART = 0x0A; 											// Line Feed
	*UART = 0x0D; 											// Carriage Return

	*aclr = 0;												// Reset board
	close(fd);
	return(0);
	
}
