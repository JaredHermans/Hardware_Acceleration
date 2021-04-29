-----------------------------------------------------------------------------------------------------------------------------------------
-- Jared Hermans
-----------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity SDRAM_CTRL is
    generic(
        MASTER_ADDRESSWIDTH             : integer;  -- Specifies how many addresses the Master can address
        SLAVE_ADDRESSWIDTH              : integer;  -- Specifies how many addresses the Slave needs to be mapped to. log(NUMREGS)
        MASTER_DATAWIDTH                : integer;  -- Specifies the Data width of SDRAM read
        SLAVE_DATAWIDTH                 : integer;  -- Specifies the Data width of Control Port
        NUMREGS                         : integer;  -- Number of Internal Registers for Custom Logic
        REGWIDTH                        : integer   -- Data width for the Internal Registers
    );
    port(
        Clk                             : in  std_logic;
        Rst_n                           : in  std_logic;
        ---------------- Exported (conduit) signals ----------------
        FIFO_Full                       : in  std_logic;
        FIFO_Data                       : out std_logic_vector(31 downto 0);
        FIFO_Write_EN                   : out std_logic;
        o_DDR_Transfer_Done             : out std_logic;
        ---------------- Avalon MM Slave Control Port Signals ----------------
        Control_Avalon_MM_Address       : IN  std_logic_vector(SLAVE_ADDRESSWIDTH - 1 downto 0);
        Control_Avalon_MM_Write         : IN  std_logic;                                       -- write request from master        
        Control_Avalon_MM_WriteData     : IN  std_logic_vector(SLAVE_DATAWIDTH - 1 downto 0);  -- Data input in response to write request
        Control_Avalon_MM_ReadData      : OUT std_logic_vector(31 downto 0);
        ---------------- Avalon MM Master Signals (SDRAM Read Master) ----------------
        SDRAM_Clk                       : in  std_logic;
        SDRAM_Rst_n                     : in  std_logic;
        SDRAM_Avalon_MM_WaitReq         : in  std_logic;                    -- Force master to stall transfer
        SDRAM_Avalon_MM_ReadData        : in  std_logic_vector(MASTER_DATAWIDTH - 1 downto 0);
        SDRAM_Avalon_MM_Read_DV         : in  std_logic;

        SDRAM_Avalon_MM_Address         : out std_logic_vector(MASTER_ADDRESSWIDTH - 1 downto 0);
        SDRAM_Avalon_MM_Burst_Count     : out std_logic_vector(7 downto 0);
        SDRAM_Avalon_MM_Read            : out std_logic                     -- Read request
    );
end entity SDRAM_CTRL;

architecture RTL of SDRAM_CTRL is

    type t_Command_Status_Regs is array (0 to NUMREGS) of std_logic_vector(REGWIDTH - 1 downto 0);
    signal w_Command_Status_Regs        : t_Command_Status_Regs;            -- Command Registers for custom logic
    
    constant START_BYTE                 : std_logic_vector(31 downto 0) := X"00000001";

    signal r_FIFO_Write_EN              : std_logic;
    signal SDRAM_Avalon_MM_Address_cld  : std_logic_vector(MASTER_ADDRESSWIDTH - 1 downto 0);

    type t_State_Type is (s_Idle, s_Receive, s_Reset);
    signal r_State                      : t_State_Type;
    signal r_current_state              : t_State_Type;

    signal Data_Counter                 : integer := 0;
    signal Burst_Counter                : std_logic_vector(7 downto 0);
    signal Total_Counter                : std_logic_vector(31 downto 0);

    signal r_Latency_Counter            : integer := 0;
    --signal r_FIFO_Full_Counter          : integer := 0;
    signal r_DDR_Transfer_Done          : std_logic;

begin
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
    -- Process describing state machine for SDRAM controller:

    p_SDRAM_FSM : process(SDRAM_Clk, SDRAM_Rst_n)
    begin

        if SDRAM_Rst_n = '1' then
            r_Current_State                                 <= s_Idle;
            -- Default Reset Values
            SDRAM_Avalon_MM_Address_cld                     <= (others => '0');
            SDRAM_Avalon_MM_Read                            <= '0';
            SDRAM_Avalon_MM_Burst_Count                     <= (others => '0');
            Burst_Counter                                   <= (others => '0');
            r_FIFO_Write_EN                                 <= '0';
            Data_Counter                                    <= 0;
        elsif rising_edge(SDRAM_Clk) then
            r_current_state                                 <= r_State;

            case r_current_state is
                when s_Idle => -- State to wait for START BYTE from Control Avalon Slave
                    if w_Command_Status_Regs(0) = START_BYTE then
                        if w_Command_Status_Regs(1) > X"000000FC" then
                            SDRAM_Avalon_MM_Burst_Count     <= X"FC";
                            Total_Counter                   <= w_Command_Status_Regs(1) - X"FC"; 
                            Burst_Counter                   <= X"FC";
                        else
                            SDRAM_Avalon_MM_Burst_Count     <= w_Command_Status_Regs(1)(7 downto 0);
                            Total_Counter                   <= (others => '0');
                            Burst_Counter                   <= w_Command_Status_Regs(1)(7 downto 0);
                        end if;
                        SDRAM_Avalon_MM_Address_cld         <= w_Command_Status_Regs(2);
                        SDRAM_Avalon_MM_Read                <= '1';
                        Data_Counter                        <= 0;
                    end if;

                when s_Receive =>
                    if Data_Counter < Burst_Counter then
                        SDRAM_Avalon_MM_Read                <= '0';
                        SDRAM_Avalon_MM_Burst_Count         <= (others => '0');
                        if (SDRAM_Avalon_MM_WaitReq = '0' and FIFO_Full = '0' and SDRAM_Avalon_MM_Read_DV = '1') then
                            FIFO_Data                       <= SDRAM_Avalon_MM_ReadData;
                            r_FIFO_Write_EN                 <= '1';
                            Data_Counter                    <= Data_Counter + 1;
                        else
                            r_FIFO_Write_EN                 <= '0';
                        end if;
                    else
                        r_FIFO_Write_EN                     <= '0';
                        SDRAM_Avalon_MM_Read                <= '0';
                        Data_Counter                        <= 0;
                    end if;

                when s_Reset =>
                    if Total_Counter > X"00000000" then
                        if Total_Counter > X"000000FC" then
                            SDRAM_Avalon_MM_Burst_Count     <= X"FC";
                            Total_Counter                   <= Total_Counter - X"FC";
                            Burst_Counter                   <= X"FC";
                        else
                            SDRAM_Avalon_MM_Burst_Count     <= Total_Counter(7 downto 0);
                            Total_Counter                   <= (others => '0');
                            Burst_Counter                   <= Total_Counter(7 downto 0);
                        end if;
                        SDRAM_Avalon_MM_Address_cld         <= SDRAM_Avalon_MM_Address_cld + X"000003F0";
                        SDRAM_Avalon_MM_Read                <= '1';
                        Data_Counter                        <= 0;
                    end if;

                when others =>
                    NULL;

            end case;
        end if;
    end process p_SDRAM_FSM;
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
    -- Process to obtain data from AXI master interface from HPS Qsys IP

    p_Avalon_Slave : process(Clk, Rst_n)
    begin
        if Rst_n = '1' then -- Do nothing
        elsif rising_edge(Clk) then
            if Control_Avalon_MM_Write = '1' then -- Control Registers set up by Avalon Slave and used in SDRAM Avalon Master
                    w_Command_Status_Regs(to_integer(unsigned(Control_Avalon_MM_Address))) <= Control_Avalon_MM_WriteData;
            end if;
        end if;
    end process p_Avalon_Slave;

    Control_Avalon_MM_ReadData              <= X"0000000" & "000" & r_DDR_Transfer_Done;
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
    -- Process for next state; combinatorial logic

    p_next_state : process (
        r_current_state,
        Data_Counter,
        w_Command_Status_Regs,
        Total_Counter,
        Burst_Counter
    )
    begin

        case r_current_state is
            when s_Idle =>
                if (w_Command_Status_Regs(0) = START_BYTE) then
                    r_state                 <= s_Receive;
                else
                    r_state                 <= s_Idle;
                end if;

            when s_Receive =>
                if Data_Counter < Burst_Counter then
                    r_state                 <= s_Receive;
                else
                    r_state                 <= s_Reset;
                end if;

            when s_Reset =>
                if (w_Command_Status_Regs(0) = X"00000000") then
                    r_state                 <= s_Idle;
                else
                    if Total_Counter > X"00000000" then
                        r_state             <= s_Receive;
                    else
                        r_state             <= s_Reset;
                    end if;
                end if;

            when others =>
                r_state                     <= s_Reset;
        end case;  
    end process p_next_state;

-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
    -- Process to assert DDR Transfer Complete signal. signal asserts when FIFO Buffer receives last
    -- data value. Look at testbench waveforms to see latency.

    p_Done : process(SDRAM_Clk)
    begin
        if rising_edge(SDRAM_Clk) then
            if r_current_state = s_Reset then
                if r_Latency_Counter < 2 then
                    r_Latency_Counter       <= r_Latency_Counter + 1;
                else
                    r_DDR_Transfer_Done     <= '1';
                end if;
            else
                r_DDR_Transfer_Done         <= '0';
                r_Latency_Counter           <= 0;
            end if;
        end if;
    end process p_Done;
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
    o_DDR_Transfer_Done                     <= r_DDR_Transfer_Done;
    SDRAM_Avalon_MM_Address                 <= SDRAM_Avalon_MM_Address_cld;
    FIFO_Write_EN                           <= r_FIFO_Write_EN;
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
    -- Process to count the number of times FIFO is full durring transfer

    --p_FIFO_FULL : process(SDRAM_Clk)
    --begin
    --    if rising_edge(SDRAM_Clk) then
    --        if r_current_state = s_Receive then
    --            if FIFO_Full = '1' then
    --                r_FIFO_Full_Counter     <= r_FIFO_Full_Counter + 1;
    --            end if;
    --        else
    --            r_FIFO_Full_Counter         <= 0;
    --        end if;
    --    end if;
    --end process p_FIFO_FULL;   

    --o_FIFO_Full_Counter                     <= std_logic_vector(to_unsigned(r_FIFO_Full_Counter,8));

-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
end architecture RTL;
