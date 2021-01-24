library ieee;
use ieee.std_logic_1164.all;

entity CONTROL is
	port(
		i_Clk 			: in  std_logic;
		i_Empty 			: in  std_logic;
		o_ena0 			: out std_logic;
		o_Read_EN 		: out std_logic
	);
end entity CONTROL;

architecture RTL of CONTROL is
	
	signal r_ena0 		: std_logic := '0';
	signal w_ena0 		: std_logic;
	
	signal w_Read_EN 	: std_logic;
	
begin

	process (i_Clk) is
	begin
		
		if rising_edge(i_Clk) then
			if i_Empty = '1' then
				r_ena0 <= '0';
			else
				r_ena0 <= '1';
			end if;
			
		end if;
	end process;
	
	w_ena0 <= r_ena0;
	o_ena0 <= w_ena0;
	
	w_Read_EN <= '1' when i_Empty = '0' else '0';
	
	o_Read_EN <= w_Read_EN;
	
end architecture RTL;
