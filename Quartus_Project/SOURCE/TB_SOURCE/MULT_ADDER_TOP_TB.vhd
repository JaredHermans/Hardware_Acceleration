-------------------------------------------------------------------------------------------------------------------------------
-- Jared Hermans
-------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity MULT_ADDER_TOP_TB is
end entity MULT_ADDER_TOP_TB;

architecture BEHAVE of MULT_ADDER_TOP_TB is

	constant c_CLK_PERIOD 		: time := 20 ns;
	
	signal r_Clk 				: std_logic := '1';
	signal r_aclr 				: std_logic := '1';
	signal r_Data 				: std_logic_vector(127 downto 0) := (others => '0');
	signal r_Data2 				: std_logic_vector(127 downto 0) := (others => '0');
	signal r_FIFO_Empty 		: std_logic := '1';
	signal r_FIFO_Empty2 		: std_logic := '1';
	signal r_DDR_Transfer_Done 	: std_logic := '0';
	signal r_DDR_Transfer_Done2 : std_logic := '0';
	
	signal w_FIFO_Read_EN 		: std_logic;
	signal w_Done 				: std_logic;
	signal w_Result 			: std_logic_vector(63 downto 0);
	signal w_Result_x 			: std_logic_vector(63 downto 0);
	signal w_Result_y 			: std_logic_vector(63 downto 0);
	
begin

	MULT_ADDER_TOP_Inst : entity work.MULT_ADDER_TOP
		port map(
			i_Clk 				=> r_Clk,
			i_aclr 				=> r_aclr,
			i_Data 				=> r_Data,
			i_FIFO_Empty 		=> r_FIFO_Empty,
			i_DDR_Transfer_Done => r_DDR_Transfer_Done,
			
			o_FIFO_Read_EN 		=> w_FIFO_Read_EN,
			o_Done 				=> w_Done,
			o_Result 			=> w_Result,
			o_Result_x 			=> w_Result_x,
			o_Result_y 			=> w_Result_y
		);
		
	r_Clk <= not r_Clk after c_CLK_PERIOD / 2;
	
	p_Clocked : process(r_Clk)
	begin
		if rising_edge(r_Clk) then
		
		end if;
	end process;
	
	process
	begin
	
		wait for c_CLK_PERIOD;
		r_aclr 				<= '0';
		wait for c_CLK_PERIOD;
		r_FIFO_Empty 		<= '0';
		r_DDR_Transfer_Done <= '1';
		wait for c_CLK_PERIOD;
		r_FIFO_Empty2 		<= '0';
		r_DDR_Transfer_Done2<= '1';
		wait for c_CLK_PERIOD;
		r_Data 				<= X"31a17bddfc178b529ac356af2fa77956";
		r_Data2 			<= X"58f6d15659a7026aeaec95cd91b8ace2";
		r_FIFO_Empty 		<= '1';
		r_FIFO_Empty2 		<= '1';
		
		wait for 3*c_CLK_PERIOD;
		assert false report "Test Complete" severity failure;
	end process;
end architecture BEHAVE;
