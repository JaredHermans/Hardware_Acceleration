# Hardware_Acceleration
Utilizing an Intel Cyclone V FPGA to accelerate the calculation time of a correlation algorithm between two sets of data

Normalized Correlation Algorithm:
<a href="https://www.codecogs.com/eqnedit.php?latex=\frac{\sum_{n=0}^{\infty}x[n]y[n]}{\sqrt{\sum_{n=0}^{\infty}x^2[n]\sum_{n=0}^{\infty}y^2[n]}}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\frac{\sum_{n=0}^{\infty}x[n]y[n]}{\sqrt{\sum_{n=0}^{\infty}x^2[n]\sum_{n=0}^{\infty}y^2[n]}}" title="\frac{\sum_{n=0}^{\infty}x[n]y[n]}{\sqrt{\sum_{n=0}^{\infty}x^2[n]\sum_{n=0}^{\infty}y^2[n]}}" /></a>

The purpose of using a FPGA for the correlation algorithm is because it involves the multiplication and addition of millions of numbers at a time. A FPGA will spend less time by allowing it to perform multiple multiplications and additions in parallel wheras a processor can only perform one task at a time. In this project, the FPGA will perform all the multiplications and additions for the algorithm and the HPS processor will perform the division and square root. 

The Intel Cyclone FPGA is booted from the SD card into U-boot which loads the FPGA bitstream. In U-Boot, a custom u-boot command is written in C to start the calculation of the algorithm. The data from x[n] and y[n] is pulled from the DDR memory into the FPGA when the calculation begins.
