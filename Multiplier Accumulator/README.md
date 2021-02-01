**FIFO_MULT5.vhd** is a module which instantiates 3 multiplier accumulator IPs. The IP is Intel FPGA Multiplier Adder IP Core. It is chosen to take 16 bit numbers
as input, a 64 bit number as output and have 4 multipliers in parallel. The IP also has enable and asynchronous clear inputs. The module also instantiates 2 FIFO IPs 
to feed the multiplier accumulators. The first multiplier accumulator is used to perform x[n]*y[n], the second to perform (x[n])^2 and the third to perform (y[n])^2. 
The module also instantiates **CONTROL.vhd** which controls the enable to the multiplier accumulators and the read enable from the buffers.

**FIFO_MULT5_TB.vhd** is the testbench for FIFO_MULT5.vhd. The testbench provides input to the module from an input txt file containing 2 columns of 64 bit numbers and 
creates an output txt file containing the results of the multiplier accumulator for x[n]*y[n].
