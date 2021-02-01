**FIFO.vhd** is a FIFO buffer written in VHDL. Read and write clocks are the same. Buffer can set width and depth in generics.

**FIFO_TB.vhd** is the testbench for FIFO.vhd.

**FIFO_IP2_TB.vhd** is the testbench for Altera's FIFO IP. The IP was chosen with separate read and write clocks, 256 words deep and 16-bits wide and asynchronous clear.

Both the IP FIFO and written FIFO demonstrate identical performance.
