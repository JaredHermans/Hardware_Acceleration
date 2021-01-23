-- Testbench for Altera FIFO IP module
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_IP2_TB is
end entity FIFO_IP2_TB;

architecture Behave of FIFO_IP2_TB is

    signal 	c_HPS_PERIOD  	: time := 10 ns;
    signal 	c_FPGA_PERIOD 	: time := 20 ns;
	 
    signal      r_aclr      	: std_logic := '0';
    signal      r_Clk_HPS   	: std_logic := '1';
    signal 	r_Clk_FPGA  	: std_logic := '1';
    signal      r_Write_EN  	: std_logic := '0';
    signal      r_Write_DATA	: std_logic_vector(15 downto 0) := X"00A5";
    signal      w_Full      	: std_logic;
    signal      r_Read_EN   	: std_logic := '0';
    signal      w_Read_Data 	: std_logic_vector(15 downto 0);
    signal      w_Empty     	: std_logic;

    component FIFO_IP2 is 	-- FIFO_IP2 is 512 words deep
        port(
            	aclr 		: in  std_logic := '0';
		data 		: in  std_logic_vector(15 downto 0);
		rdclk 		: in  std_logic;
		rdreq 		: in  std_logic;
		wrclk 		: in  std_logic;
		wrreq 		: in  std_logic;
		q 		: out std_logic_vector(15 downto 0);
		rdempty 	: out std_logic;
		wrfull 		: out std_logic
	);
    end component FIFO_IP2;
	  
begin

    FIFO_IP_Inst : FIFO_IP2
	port map(
		aclr 		=> r_aclr,
		data 		=> r_Write_Data,
		rdclk 		=> r_Clk_FPGA,
		rdreq 		=> r_Read_EN,
		wrclk 		=> r_Clk_HPS,
		wrreq 		=> r_Write_EN,
		q 		=> w_Read_Data,
		rdempty 	=> w_Empty,
		wrfull 		=> w_Full
	);

	 r_Clk_HPS 	<= not r_Clk_HPS after c_HPS_PERIOD / 2;
	 r_Clk_FPGA 	<= not r_Clk_FPGA after c_FPGA_PERIOD / 2;

    p_TB : process is
    begin

      wait for 20 ns;
		r_Write_Data		<= X"00FF";
		r_Write_EN 		<= '1';
		wait for 10 ns;
		r_Write_EN 		<= '0';
		wait for 50 ns;
		r_Write_Data   		<= X"0F00";
		r_Write_EN 		<= '1';
		wait for 10 ns;
		r_Write_EN 		<= '0';
		wait for 50 ns;
		r_Write_Data 		<= X"F000";
		r_Write_EN 		<= '1';
		wait for 10 ns;
		r_Write_EN 		<= '0';
		wait for 50 ns;
		r_Read_EN 		<= '1';
		wait for 20 ns;
		r_Read_En 		<= '0';
		wait for 20 ns;
		r_Read_EN 		<= '1';
		wait for 20 ns;
		r_Read_EN 		<= '0';
		wait for 20 ns; 
		r_Read_EN 		<= '1';
		wait for 20 ns;
		r_Read_EN 		<= '0';
		wait for 20 ns;
		r_Read_EN 		<= '0';
		wait for 20 ns;
		r_aclr 			<= '1';
		wait for 40 ns;
		r_aclr	 		<= '0';
		r_Write_Data 		<= X"000F";
		r_Write_EN 		<= '1';
		wait for 10 ns;
		r_Write_Data 		<= X"00F0";
		wait for 10 ns;
		r_Write_Data 		<= X"0F00";
		wait for 10 ns;
		r_Write_Data 		<= X"F000";
		wait for 10 ns;
		r_Write_Data 		<= X"FFFF";
		wait for 10 ns;
		r_Write_EN 		<= '0';
		wait for 30 ns;
		r_Read_EN 		<= '1';
		wait for 100 ns;
		r_Read_EN 		<= '0';
		wait for 40 ns;
		
		assert false report "Test Complete" severity failure;
        
    end process p_TB;

end architecture Behave;
