------------------------------------------------------------------------------------------------
-- Jared Hermans
--
-- Description:     Module creates a synchronous FIFO made out of registers.
--                  c_WIDTH sets the width of the FIFO.
--                  c_DEPTH sets the depth of the FIFO.
--
--                  The total FIFO registers used will be width * depth.
--                  Read and write clocks need to be the same frequency.
--
--                  o_FIFO_Full will go high as soon as last word is written
--                  o_FIFO_Empty will go high as soon as the last word is read.
--
--                  Assert statements are not synthesized however they are needed 
--                  for simulation.
--                  
--                  
------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO is
    generic(
        c_WIDTH         : natural   := 16;
        c_DEPTH         : integer   := 4;	-- 1 less then value. EX: c_DEPTH = 5 ; actual DEPTH = 4
        c_AF_LEVEL      : integer   := 3;
        c_AE_LEVEL      : integer   := 2
    );
    port(
        i_Rst_Sync      : in  std_logic;
        i_Clk           : in  std_logic;

        -- FIFO Write Signals
        i_Write_EN      : in  std_logic;
        i_Write_Data    : in  std_logic_vector(c_WIDTH - 1 downto 0);
        o_Almost_Full   : out std_logic;
        o_Full          : out std_logic;

        --FIFO Read Signals
        i_Read_EN       : in  std_logic;
        o_Read_Data     : out std_logic_vector(c_WIDTH - 1 downto 0);
        o_Almost_Empty  : out std_logic;
        o_Empty         : out std_logic
    );
end entity FIFO;

architecture RTL of FIFO is

    type t_FIFO_Data is array (0 to c_DEPTH - 1) of std_logic_vector(c_WIDTH - 1 downto 0);     -- type array
    signal r_FIFO_Data      : t_FIFO_Data := (others => (others => '0'));                       -- Settint inital value of array to 0

    signal r_Write_Index    : integer range 0 to c_DEPTH := 1;
    signal r_Read_Index     : integer range 0 to c_DEPTH - 1 := 0;

    signal r_FIFO_Count     : integer range -1 to c_DEPTH + 1 := 0;

    signal w_Full           : std_logic;
    signal w_Empty          : std_logic;
	 
	 signal r_Count 			 : std_logic := '0';
	 
	 constant c_Initial 		 : integer := 0;

begin

    p_CONTROL : process (i_Clk) is
    begin
        if rising_edge(i_Clk) then

            if i_Rst_Sync = '1' then
                r_FIFO_COUNT    <= 0;
                r_Write_Index   <= 1;
                r_Read_Index    <= 0;
            else
                
					 -- Take care of initial case:
					 if i_Write_EN = '1' and i_Read_EN = '1' then
						  if r_FIFO_Count = c_Initial then
							   r_FIFO_Count <= 1;
						  end if;
					 end if;
					 
                -- Keep track of the total number of words in the FIFO
                if i_Write_EN = '1' and i_Read_EN = '0' then
                    r_FIFO_Count <= r_FIFO_Count + 1;
                elsif i_Write_EN = '0' and i_Read_EN = '1' then
                    if r_FIFO_Count = 0 then
							  r_FIFO_Count <= 0;
						  else
							  r_FIFO_Count <= r_FIFO_Count - 1;
						  end if;
                end if;

                -- Keep track of the write index and controls roll-over
                if i_Write_EN = '1' and w_Full = '0' then
						  if r_Write_Index /= c_DEPTH - 1 then
							  if r_Write_Index = c_DEPTH then
									r_Write_Index <= 1;
							  else
									r_Write_Index <= r_Write_Index + 1;
							  end if;
						  end if;
                end if;

                -- Keep track of the read index and controls roll-over
                if i_Read_EN = '1' and w_Empty = '0' then
                    if r_Read_Index = c_DEPTH - 1 then
                        r_Read_Index <= 0;
                    else
                        r_Read_Index <= r_Read_Index + 1;
                    end if;
                end if;
            
                -- When there is a write, register the input data
                if i_Write_EN = '1' then
                    r_FIFO_Data(r_Write_Index) <= i_Write_Data;
                end if;

            end if;
        end if;
    end process p_CONTROL;
	
    o_Read_Data     <= r_FIFO_Data(r_Read_Index);

    w_Full          <= '1' when r_FIFO_Count = c_DEPTH - 1 else '0';
    w_Empty         <= '1' when r_FIFO_Count = 0        else '0';

    o_Almost_Full   <= '1' when r_FIFO_Count > c_AF_LEVEL else '0';
    o_Almost_Empty  <= '1' when r_FIFO_Count > c_AE_LEVEL else '0';

    o_Full <= w_Full;
    o_Empty <= w_Empty;

    ---------------------------------------------------------------------------
    -- Assertion Logic (not synthesized)
    ---------------------------------------------------------------------------
    -- synthesis translate_off

    p_ASSERT : process(i_Clk) is
    begin
        if rising_edge(i_Clk) then
            if i_Write_EN = '1' and w_Full = '1' then
                report "Assert Failure - FIFO is full and is being written ";
            end if;

            if i_Read_EN = '1' and w_Empty = '1' then
                report "Assert Failure - FIFO is empty and being read ";
            end if;
        end if;
    end process p_ASSERT;

    -- synthesis translate_on

end architecture RTL;
