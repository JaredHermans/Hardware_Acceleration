/////////////////////////////////////////////////////////////////////////////////////////////
//	Jared Hermans
/////////////////////////////////////////////////////////////////////////////////////////////
#include <common.h>
#include <command.h>
#include <asm/io.h>
#include <asm/processor.h>

#define FPGA_AXI_BASE           0xC0000000      // AXI Master
#define FPGA_AXI_LW_BASE        0xFF200000      // AXI LW

#define SYSID_BASE              0x00
#define DDR1_BASE               0x10
#define O_CONTROL_BASE          0x30
#define I_CONTROL_BASE          0x40
#define TIME_BASE               0x50
#define TIME2_BASE              0x60
#define TIME3_BASE              0x70
#define BLUETOOTH_BASE 		    0x80

#define XY_DATAA_BASE 		    0x00
#define XY_DATAB_BASE           0x10
#define XX_DATAA_BASE 		    0x20
#define XX_DATAB_BASE 		    0x30
#define YY_DATAA_BASE 		    0x40
#define YY_DATAB_BASE 		    0x50

#define WAIT {}

#define HIBIT                   0x8000000000000000ULL

#define msleep(a) udelay(a * 1000)

typedef struct
{
    uint64_t hi;
    uint64_t lo;
    short isneg;    
    short isbig;    
} qofint128;

int cmp128(qofint128 a, qofint128 b);

qofint128 mult128(uint64_t a, uint64_t b);

uint64_t LSB(uint64_t);

uint64_t MSB(uint64_t);

void MULT(uint64_t, uint64_t, uint64_t*, uint64_t*);            // Multiply 2 64-bit numbers

uint64_t sqrt_x(qofint128);                                     // Square root of 128-bit number

int intToAscii(int number);

void Bluetooth(uint32_t, uint8_t);

//static int do_ddr(cmd_tbl_t *cmdtp, int flag, int argc, char * const argv[])            // U-Boot 2013 (Intel EDS 2016)
static int do_ddr(struct cmd_tbl *cmdtp, int flag, int argc, char *const argv[])        // U-Boot 2020 (Intel EDS 2020)
{
    printf("\nStarting Custom U-BOOT Command:\n");

    double ans, Total_Time;
    uint32_t sysid, Time, Time2, Time3;
    uint64_t xy_Data, xx_Data, yy_Data, sq;
    qofint128 mult;
    char ch;

    sysid = readl(FPGA_AXI_LW_BASE);
    printf("\nSysid = %.16X\n\n", sysid);

    ////////// Set up DDR1 //////////
    writel(0x30000000, FPGA_AXI_LW_BASE + DDR1_BASE + 0x8);         // set start address
    printf("Test? y/n: ");
    ch = getc();
    if(ch == 'y') {
        writel(0x00000008, FPGA_AXI_LW_BASE + DDR1_BASE + 0x4);     // set number of transfers
        printf("\nAddress 0x30000000 - 0x30000020; Number of input values: 8 x 2\n\n");
    }
    else if(ch == 'n') {
        writel(0x001FA400, FPGA_AXI_LW_BASE + DDR1_BASE + 0x4);     // set number of transfers
        printf("\nAddress 0x30000000 - 0x307E9000; Number of input values: 2,073,600 x 2\n\n");
    }
    else {
        printf("\n");
        return(0);
    }

    ////////// Reset aclr and start DMA //////////
    writel(0x00000000, FPGA_AXI_LW_BASE + O_CONTROL_BASE);          // set aclr = 1
    writel(0x00000001, FPGA_AXI_LW_BASE + O_CONTROL_BASE);          // set aclr = 0 - starts timer in FPGA
    writel(0x00000001, FPGA_AXI_LW_BASE + DDR1_BASE);               // start DMA1

    ////////// Wait for FPGA Done Signal //////////
    while(readl(FPGA_AXI_LW_BASE + I_CONTROL_BASE) == 0x0) WAIT;

    ////////// Read Calculated Values //////////
    xy_Data = readl(FPGA_AXI_BASE + XY_DATAA_BASE) | (((uint64_t) readl(FPGA_AXI_BASE + XY_DATAB_BASE)) << 32); // Reading values from FPGA
    xx_Data = readl(FPGA_AXI_BASE + XX_DATAA_BASE) | (((uint64_t) readl(FPGA_AXI_BASE + XX_DATAB_BASE)) << 32);
    yy_Data = readl(FPGA_AXI_BASE + YY_DATAA_BASE) | (((uint64_t) readl(FPGA_AXI_BASE + YY_DATAB_BASE)) << 32);

    mult = mult128(xx_Data, yy_Data);           // Multiply 2 64 bit numbers. Result must be stored in 2 64 bit numbers; U-Boot doesn't support 128-bit integer

    sq = sqrt_x(mult);                          // Square root of 128 bit number

    ans = (double) xy_Data / sq;                // Divide 2 64 bit numbers

    writel(0x00000003, FPGA_AXI_LW_BASE + O_CONTROL_BASE);          // Send done signal to FPGA (Stop Timer)
    writel(0x00000000, FPGA_AXI_LW_BASE + DDR1_BASE);               // Reset DMA1

    printf("xy_Data = 0x%.16llX\n", xy_Data);
    printf("xx_Data = 0x%.16llX\n", xx_Data);
    printf("yy_Data = 0x%.16llX\n", yy_Data);

    Time = readl(FPGA_AXI_LW_BASE + TIME_BASE);
    printf("\nClock cycles to complete DMA transfer: %u\n", Time);
    Time2 = readl(FPGA_AXI_LW_BASE + TIME2_BASE);
    printf("Clock cycles to complete FPGA Calculation: %u\n", Time2);
    Time3 = readl(FPGA_AXI_LW_BASE + TIME3_BASE);
    printf("Clock cycles to complete HPS Calculation: %u\n", Time3);

    printf("\nxx_Data * yy_Data = %.16llX%.16llX\n", mult.hi, mult.lo);
    printf("\nSquare root of %.16llX%.16llX is %.16llX\n", mult.hi, mult.lo, sq);

    Total_Time = (double) Time3 / 50000000;                         // Find time in seconds from number of clock cycles

    writel(0x00000030, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);          // 0
    writel(0x0000002E, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);          // .
    Bluetooth((uint32_t) (ans * 1000000000.0),9);
    writel(0x0000002C, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);          // ,
    writel(0x00000030, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);          // 0
    writel(0x0000002E, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);          // .
    Bluetooth((uint32_t) (Total_Time * 1000000000), 9);
    writel(0x0000000A, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);          // Line Feed
    writel(0x0000000D, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);          // Carriage Return

    return(0);
}

U_BOOT_CMD(ddr, CONFIG_SYS_MAXARGS, 1, do_ddr, "Custom ddr",
        "[args..]\n"
        "   - echo args to console; \\c suppresses newline"
        );

//static int do_write(cmd_tbl_t *cmdtp, int flag, int argc, char * const argv[])          // U-Boot 2013 (Intel EDS 2016)
static int do_write(struct cmd_tbl *cmdtp, int flag, int argc, char *const argv[])    // U-Boot 2020 (Intel EDS 2020)
{
    uint32_t addr = 0x30000000;
    for(int i = 0; i < 259200; i++) {
        writel(0x31a17bdd, addr);
        writel(0xfc178b52, addr + 0x04);
        writel(0x58f6d156, addr + 0x08);
        writel(0x59a7026a, addr + 0x0C);
        writel(0x9ac356af, addr + 0x10);
        writel(0x2fa77956, addr + 0x14);
        writel(0xeaec95cd, addr + 0x18);
        writel(0x91b8ace2, addr + 0x1C);
        addr = addr + 0x20;
        }
    return(0);
}

U_BOOT_CMD(write, CONFIG_SYS_MAXARGS, 1, do_write, "Custom write",
        "[args..]\n"
        "   - echo args to console; \\c suppresses newline"
        );

static int do_bluetooth(struct cmd_tbl *cmdtp, int flag, int argc, char *const argv[])    // U-Boot 2020 (Intel EDS 2020)
//static int do_bluetooth(cmd_tbl_t *cmdtp, int flag, int argc, char * const argv[])          // U-Boot 2013 (Intel EDS 2016)
{
    writel(0x00000030, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // 0
    writel(0x0000002E, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // .
    writel(0x00000031, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // 1
    writel(0x00000032, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // 2
    writel(0x00000033, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // 3
    writel(0x0000002C, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // ,
    writel(0x00000030, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // 0
    writel(0x0000002E, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // .
    writel(0x00000031, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // 1
    writel(0x00000032, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // 2
    writel(0x00000033, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // 3
    writel(0x0000000A, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // Line Feed
    writel(0x0000000D, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);      // Carriage Return
    return(0);
}

U_BOOT_CMD(bluetooth, CONFIG_SYS_MAXARGS, 1, do_bluetooth, "Custom write",
        "[args..]\n"
        "   - echo args to console; \\c suppresses newline"
        );

qofint128 mult128(uint64_t a, uint64_t b)
{
    qofint128 prod;
    uint64_t a0, a1;
    uint64_t b0, b1;
    uint64_t d, d0, d1;
    uint64_t e, e0, e1;
    uint64_t f, f0, f1;
    uint64_t g, g0, g1;    
    uint64_t sum, carry, roll, pmax;

    prod.isneg = 0;
    if (0 > a)
    {
        prod.isneg = !prod.isneg;
        a = -a;
    }

    if (0 > b)
    {
        prod.isneg = !prod.isneg;
        b = -b;
    }

    a1 = a >> 32;
    a0 = a - (a1 << 32);

    b1 = b >> 32;
    b0 = b - (b1 << 32);

    d = a0 * b0;
    d1 = d >> 32;
    d0 = d - (d1 << 32);

    e = a0 * b1;
    e1 = e >> 32;
    e0 = e - (e1 << 32);

    f = a1 * b0;
    f1 = f >> 32;
    f0 = f - (f1 << 32);

    g = a1 * b1;
    g1 = g >> 32;
    g0 = g - (g1 << 32);

    sum = d1 + e0 + f0;
    carry = 0;
    /* Can't say 1<<32 cause cpp will goof it up; 1ULL<<32 might work */
    roll = 1 << 30;
    roll <<= 2;

    pmax = roll - 1;
    while (pmax < sum)
    {
        sum -= roll;
        carry ++;
    }
    prod.lo = d0 + (sum << 32);
    prod.hi = carry + e1 + f1 + g0 + (g1 << 32);
    // prod.isbig = (prod.hi || (sum >> 31));
    prod.isbig = prod.hi || (prod.lo >> 63);

    return prod;
}

int cmp128(qofint128 a, qofint128 b)
{
    if ((0 == a.isneg) && b.isneg) return 1;
    if (a.isneg && (0 == b.isneg)) return -1;
    if (0 == a.isneg)
    {
        if (a.hi > b.hi) return 1;
        if (a.hi < b.hi) return -1;
        if (a.lo > b.lo) return 1;
        if (a.lo < b.lo) return -1;
        return 0;
    }

    if (a.hi > b.hi) return -1;
    if (a.hi < b.hi) return 1;
    if (a.lo > b.lo) return -1;
    if (a.lo < b.lo) return 1;
    return 0;
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

uint64_t sqrt_x(qofint128 n)
{
        uint64_t Bit;
        uint64_t root = 0;
        for(Bit = 0x8000000000000000ull; Bit > 0; Bit >>= 1) {
            uint64_t trial = root + Bit;
            qofint128 tmp = mult128(trial,trial);
            if(cmp128(tmp,n) < 0)
                root += Bit;
        }
    return root;
}

int intToAscii(int number)
{
    return '0' + number;
}

void Bluetooth(uint32_t N, uint8_t size)
{
    uint32_t r;
    uint32_t Print = 0;

    Print &= ~0xFFFFFFFFu;
    if (N == 0 && size == 0)
        return;
    // Extract last digit
    r = N % 10;
    // Recursive call to next iteration
    Bluetooth(N / 10, size - 1);

    Print |= intToAscii(r);
    writel(Print, FPGA_AXI_LW_BASE + BLUETOOTH_BASE);
    size -= 1;
}