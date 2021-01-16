LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY FIFO_TB IS
END FIFO_TB;
ARCHITECTURE BEHAVE OF FIFO_TB IS

	constant c_CLK_PERIOD 	: time 		:= 20 ns;
	
	SIGNAL r_Clk 				: STD_LOGIC := '0';
	SIGNAL r_Read_EN 			: STD_LOGIC := '0';
	SIGNAL r_Rst_Sync 			: STD_LOGIC := '0';
	SIGNAL r_Write_Data 			: STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	SIGNAL r_Write_EN 			: STD_LOGIC := '0';
	
	SIGNAL w_Almost_Empty 			: STD_LOGIC;
	SIGNAL w_Almost_Full 			: STD_LOGIC;
	SIGNAL w_Empty 				: STD_LOGIC;
	SIGNAL w_Full 				: STD_LOGIC;
	SIGNAL w_Read_Data 			: STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	COMPONENT FIFO
		PORT (
		i_Clk 				: IN  STD_LOGIC;
		i_Read_EN 			: IN  STD_LOGIC;
		i_Rst_Sync 			: IN  STD_LOGIC;
		i_Write_Data 			: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		i_Write_EN 			: IN  STD_LOGIC;
		o_Almost_Empty 			: OUT STD_LOGIC;
		o_Almost_Full 			: OUT STD_LOGIC;
		o_Empty 			: OUT STD_LOGIC;
		o_Full 				: OUT STD_LOGIC;
		o_Read_Data 			: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;
	
BEGIN

		i1 : FIFO
		PORT MAP (
	-- list connections between master ports and signals
		i_Clk 				=> r_Clk,
		i_Read_EN 			=> r_Read_EN,
		i_Rst_Sync 			=> r_Rst_Sync,
		i_Write_Data 			=> r_Write_Data,
		i_Write_EN 			=> r_Write_EN,
		o_Almost_Empty 			=> w_Almost_Empty,
		o_Almost_Full 			=> w_Almost_Full,
		o_Empty 			=> w_Empty,
		o_Full 				=> w_Full,
		o_Read_Data 			=> w_Read_Data
		);
		
	r_Clk <= not r_Clk after c_CLK_PERIOD / 2;
		
	init : PROCESS 
	BEGIN          
		
		wait for 30 ns;
		r_Write_Data		<= X"00FF";
		r_Write_EN 		<= '1';
		wait for 20 ns;
		r_Write_EN 		<= '0';
		wait for 40 ns;
		r_Write_Data  		<= X"0F00";
		r_Write_EN 		<= '1';
		wait for 20 ns;
		r_Write_EN 		<= '0';
		wait for 40 ns;
		r_Write_Data 		<= X"F000";
		r_Write_EN 		<= '1';
		wait for 20 ns;
		r_Write_EN 		<= '0';
		wait for 40 ns;
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
		r_Rst_Sync 		<= '1';
		wait for 40 ns;
		r_Rst_Sync 		<= '0';
		r_Write_Data 		<= X"000F";
		r_Write_EN 		<= '1';
		wait for 20 ns;
		r_Read_EN 		<= '1';
		r_Write_Data 		<= X"00F0";
		wait for 20 ns;
		r_Write_Data 		<= X"0F00";
		wait for 20 ns;
		r_Write_EN 		<= '0';
		wait for 20 ns;
		r_Read_EN 		<= '0';
		wait for 40 ns;
		
		assert false report "Test Complete" severity failure;
		
	END PROCESS init;                                           
	                                         
END BEHAVE;
