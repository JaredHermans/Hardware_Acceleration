-------------------------------------------------------------------------------------------------------------------------------
-- Jared Hermans
-------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Binary_To_7Segment is
    port (
        i_Clk           : in std_logic;
        i_Binary_Num    : in std_logic_vector (3 downto 0);
        o_Segment_A     : out std_logic;
        o_Segment_B     : out std_logic;
        o_Segment_C     : out std_logic;
        o_Segment_D     : out std_logic;
        o_Segment_E     : out std_logic;
        o_Segment_F     : out std_logic;
        o_Segment_G     : out std_logic
    );
end entity Binary_To_7Segment;

architecture RTL of Binary_To_7Segment is

    signal r_Hex_Encoding : std_logic_vector(7 downto 0 ) := (others => '0');

begin

    process (i_Clk) is
    begin
        if rising_edge(i_Clk) then
            case i_Binary_Num is
                when "0000" => r_Hex_encoding <= X"7E";              --hex assignment
                when "0001" => r_Hex_encoding <= X"30";
                when "0010" => r_Hex_encoding <= X"6D";
                when "0011" => r_Hex_encoding <= X"79";
                when "0100" => r_Hex_encoding <= X"33";
                when "0101" => r_Hex_encoding <= X"5B";
                when "0110" => r_Hex_encoding <= X"5F";
                when "0111" => r_Hex_encoding <= X"70";
                when "1000" => r_Hex_encoding <= X"7F";
                when "1001" => r_Hex_encoding <= X"7B";
                when "1010" => r_Hex_encoding <= X"77";
                when "1011" => r_Hex_encoding <= X"1F";
                when "1100" => r_Hex_encoding <= X"4E";
                when "1101" => r_Hex_encoding <= X"3D";
                when "1110" => r_Hex_encoding <= X"4F";
                when "1111" => r_Hex_encoding <= X"47";
		when others => r_Hex_encoding <= X"7E";
            end case;
        end if;
    end process;

    --r_Hex_Encoding(7) is unused
    o_Segment_A <= r_Hex_encoding(6);
    o_Segment_B <= r_Hex_encoding(5);
    o_Segment_C <= r_Hex_encoding(4);
    o_Segment_D <= r_Hex_encoding(3);
    o_Segment_E <= r_Hex_encoding(2);
    o_Segment_F <= r_Hex_encoding(1);
    o_Segment_G <= r_Hex_encoding(0);

end architecture RTL;
