-------------------------------------------------------------------------------------------------------------------------------
-- Jared Hermans
-------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timer is
	port(
		i_Clk 		: in  std_logic;
		i_aclr 		: in  std_logic;
		i_done 		: in  std_logic;
		
		o_Time 		: out std_logic_vector(25 downto 0)
	);
end entity Timer;

architecture RTL of Timer is

	constant c_MAX 		: integer := 50000000; 					-- Maximum time count is 1 second
	signal r_Count 		: natural range 0 to 50000000 := 0;
	signal r_Time 		: std_logic_vector(25 downto 0) := (others => '0');
	
begin

	process (i_Clk,i_aclr) is
	begin
		if i_aclr = '1' then
			r_Count 			<= 0;
			r_Time 				<= std_logic_vector(to_unsigned(r_Count,26));
		elsif rising_edge(i_Clk) then
			if i_done /= '1' and r_Count /= c_MAX then
				r_Count 		<= r_Count + 1;
			elsif i_done = '1' then
				r_Time 			<= std_logic_vector(to_unsigned(r_Count,26));
			end if;			
		end if;
	end process;
	
	o_Time <= r_Time;
	
end architecture RTL;
		
