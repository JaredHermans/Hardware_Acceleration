-------------------------------------------------------------------------------------------------------------------------------
-- Jared Hermans
-------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.numeric_std_unsigned.all; -- used for vector addition

entity MULT_ADDER_TOP is
	port(
		i_Clk 				: in  std_logic;
		i_aclr 				: in  std_logic;
		i_Data 				: in  std_logic_vector(127 downto 0);
		i_FIFO_Empty 		: in  std_logic;
		i_DDR_Transfer_Done : in  std_logic;
		
		o_FIFO_Read_EN 		: out std_logic;
		o_Done 				: out std_logic;
		o_Result 			: out std_logic_vector(63 downto 0);
		o_Result_x 			: out std_logic_vector(63 downto 0);
		o_Result_y 			: out std_logic_vector(63 downto 0)
	);
end entity MULT_ADDER_TOP;

architecture RTL of MULT_ADDER_TOP is

	signal w_FIFO_Read_EN   : std_logic;
	signal w_MULT_EN 		: std_logic;

	component MULT_ADDER_IP is
		port(
			result 			: out std_logic_vector(63 downto 0);
			dataa_0 		: in  std_logic_vector(15 downto 0);
			dataa_1 		: in  std_logic_vector(15 downto 0);
			dataa_2 		: in  std_logic_vector(15 downto 0);
			dataa_3 		: in  std_logic_vector(15 downto 0);
			datab_0 		: in  std_logic_vector(15 downto 0);
			datab_1 		: in  std_logic_vector(15 downto 0);
			datab_2 		: in  std_logic_vector(15 downto 0);
			datab_3 		: in  std_logic_vector(15 downto 0);
			
			clock0 			: in  std_logic;
			ena0 			: in  std_logic;
			aclr0 			: in  std_logic
		);
	end component MULT_ADDER_IP;

begin

	MULT_ADDER_XY1_Inst : MULT_ADDER_IP
		port map(
			result 			=> o_Result,
			dataa_0 		=> i_Data(15 downto 0),
			dataa_1 		=> i_Data(31 downto 16),
			dataa_2 		=> i_Data(47 downto 32),
			dataa_3 		=> i_Data(63 downto 48),
			datab_0 		=> i_Data(79 downto 64),
			datab_1 		=> i_Data(95 downto 80),
			datab_2 		=> i_Data(111 downto 96),
			datab_3 		=> i_Data(127 downto 112),
			
			clock0 			=> i_Clk,
			ena0 			=> w_MULT_EN,
			aclr0 			=> i_aclr
		);
		
	MULT_ADDER_XX1_Inst : MULT_ADDER_IP
		port map(
			result 			=> o_Result_x,
			dataa_0 		=> i_Data(15 downto 0),
			dataa_1 		=> i_Data(31 downto 16),
			dataa_2 		=> i_Data(47 downto 32),
			dataa_3 		=> i_Data(63 downto 48),
			datab_0 		=> i_Data(15 downto 0),
			datab_1 		=> i_Data(31 downto 16),
			datab_2 		=> i_Data(47 downto 32),
			datab_3 		=> i_Data(63 downto 48),
			
			clock0 			=> i_Clk,
			ena0 			=> w_MULT_EN,
			aclr0 			=> i_aclr
		);
		
	MULT_ADDER_YY1_Inst : MULT_ADDER_IP
		port map(
			result 			=> o_Result_y,
			dataa_0 		=> i_Data(79 downto 64),
			dataa_1 		=> i_Data(95 downto 80),
			dataa_2 		=> i_Data(111 downto 96),
			dataa_3 		=> i_Data(127 downto 112),
			datab_0 		=> i_Data(79 downto 64),
			datab_1 		=> i_Data(95 downto 80),
			datab_2 		=> i_Data(111 downto 96),
			datab_3 		=> i_Data(127 downto 112),
			
			clock0 			=> i_Clk,
			ena0 			=> w_MULT_EN,
			aclr0 			=> i_aclr
		);

	p_MULT_EN : process(i_Clk,i_aclr) -- Register MULT_EN 1 clock cycle behing FIFO_Read_EN
	begin
		if i_aclr = '1' then
			w_MULT_EN 		<= '0';
		elsif rising_edge(i_Clk) then
			if w_FIFO_Read_EN = '1' then
				w_MULT_EN 	<= '1';
			else
				w_MULT_EN 	<= '0';
			end if;
		end if;
	end process p_MULT_EN;

	w_FIFO_Read_EN 		<= '1' when i_FIFO_Empty = '0' else '0';
	o_FIFO_Read_EN 	 	<= w_FIFO_Read_EN;
	
	o_Done 				<= '1' 
		when (w_MULT_EN = '0' and i_FIFO_Empty = '1' and i_DDR_Transfer_Done = '1')
		else '0';
		
end architecture RTL;
