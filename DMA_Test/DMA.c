#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <malloc.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ipc.h> 
#include <sys/shm.h> 
#include <sys/mman.h>
#include <sys/time.h> 
#include <math.h> 

#define AXI_MASTER_BASE             0xC0000000 // 0xFFE01000
#define AXI_MASTER_SPAN             0x00010000

// Addresses on lw AXI Buss
#define AXI_LW_BASE                 0xFF200000
#define AXI_LW_SPAN                 0xF0000000

// DMA Addresses on AXI Master
#define DMA_STATUS_OFFSET           0x00
#define DMA_READ_ADD_OFFSET         0x01
#define DMA_WRITE_ADD_OFFSET        0x02
#define DMA_LENGTH_OFFSET           0x03
#define DMA_CONTROL_OFFSET          0x06

// Pointers for DMA Addresses
void *axi_master_virtual_base;
volatile __uint32_t *DMA_base_ptr   = NULL;

// HPS onchip memory
#define HPS_ONCHIP_BASE             0xFFFF0000
#define HPS_ONCHIP_SPAN             0x00010000

// Pointers for HPS onchip memory
void *hps_onchip_virtual_base;
volatile __uint32_t *hps_onchip_ptr = NULL;

#define WAIT {}
int fd;         // /dev/mem file

struct timeval t1, t2;

int main(void)
{
    // Open /dev/mem:
	if((fd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1) 	
    {
		printf("ERROR: could not open \"/dev/mem\"...\n");
		return(1);
	}


    axi_master_virtual_base = mmap(NULL, AXI_MASTER_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, AXI_MASTER_BASE);	
	if(axi_master_virtual_base == MAP_FAILED) 
    {
		printf("ERROR: mmap1() failed...\n");
		close(fd);
		return(1);
	}

    // the DMA registers:
	DMA_base_ptr = (__uint32_t *)(axi_master_virtual_base);

    // HPS onchip ram 
	hps_onchip_virtual_base = mmap(NULL, HPS_ONCHIP_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, HPS_ONCHIP_BASE); 	
	
	if(hps_onchip_virtual_base == MAP_FAILED) 
    {
		printf("ERROR: mmap3() failed...\n");
		close(fd);
		return(1);
	}
    // Get the address that maps to the HPS ram
	hps_onchip_ptr =(__uint32_t *)(hps_onchip_virtual_base);

    int N;
    int i, j;
    double elapsedTime;
    __uint32_t send[4][2] = {
        {0x31a17bdd, 0x58f6d156},
        {0xfc178b52, 0x59a7026a},
        {0x9ac356af, 0xeaec95cd},
        {0x2fa77956, 0x91b8ace2}
    };
    __uint32_t receive[2][4];

    while(1)
    {
        printf("\n\r enter number");
		scanf("%d", &N);

		printf("================\n\r");
        printf("\nPrinting Send Data:\n");
        for (i = 0; i < 4; i++)
        {
			for(j = 0; j < 2; j++)
            {
                printf("%X ", send[i][j]);
                if(j == 1) printf("\n");
            }
		}

        printf("before memcpy\n");
        // ======== Put data in onchip RAM ========
        memcpy((void *) hps_onchip_ptr, (const void*) &send, sizeof(send));
        printf("after memcpy\n");

        *(DMA_base_ptr) = 0;                                 // Set DMA to read
        *(DMA_base_ptr + DMA_READ_ADD_OFFSET) = 0xFFFF0000;  // Qsys peripheral to read data
        *(DMA_base_ptr + DMA_WRITE_ADD_OFFSET) = 0x00000000; // Qsys peripheral to write data
        *(DMA_base_ptr + DMA_LENGTH_OFFSET) = sizeof(send);  // Number of bytes to transfer
        gettimeofday(&t1, NULL);
        *(DMA_base_ptr + DMA_CONTROL_OFFSET) = 0b1010001100; // Starts transfer
        while((*DMA_base_ptr & 0x010) == 0) 
        {
            WAIT;
        }
        gettimeofday(&t2, NULL);
        elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000000.0 ;
        elapsedTime = (t2.tv_usec - t1.tv_usec);
        printf("DMA Transfer took %f usec\n", elapsedTime);
        printf("After while loop\n");
        close(fd);
        return(0);
    }
}
