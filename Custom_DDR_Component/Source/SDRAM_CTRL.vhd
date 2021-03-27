library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity SDRAM_CTRL is
    generic(
        MASTER_ADDRESSWIDTH           : integer;  -- Specifies how many addresses the Master can address
        SLAVE_ADDRESSWIDTH            : integer;  -- Specifies how many addresses the Slave needs to be mapped to. log(NUMREGS)
        MASTER_DATAWIDTH              : integer;  -- Specifies the Data width of SDRAM read
        SLAVE_DATAWIDTH               : integer;  -- Specifies the Data width of Control Port
        NUMREGS                       : integer;  -- Number of Internal Registers for Custom Logic
        REGWIDTH                      : integer   -- Data width for the Internal Registers
    );
    port(
        FIFO_Full                       : in  std_logic;

        FIFO_Data                       : out std_logic_vector(31 downto 0);
        FIFO_Write_EN                   : out std_logic;
        ---------------- Avalon MM Slave Control Port Signals ----------------
        Control_Avalon_MM_Address       : IN     std_logic_vector(SLAVE_ADDRESSWIDTH - 1 downto 0);
        --Control_Avalon_MM_CS            : IN     std_logic;
        Control_Avalon_MM_Write         : IN     std_logic;                                   -- write request from master        
        Control_Avalon_MM_WriteData     : IN     std_logic_vector(SLAVE_DATAWIDTH - 1 downto 0);  -- Data input in response to write request
        -------- Avalon MM Master Signals (SDRAM Read Master) ----------------
        SDRAM_Clk                       : in  std_logic;
        SDRAM_Rst_n                     : in  std_logic;
        SDRAM_Avalon_MM_WaitReq         : in  std_logic;                    -- Force master to stall transfer
        SDRAM_Avalon_MM_ReadData        : in  std_logic_vector(MASTER_DATAWIDTH - 1 downto 0);
        SDRAM_Avalon_MM_Read_DV         : in  std_logic;

        SDRAM_Avalon_MM_Address         : out std_logic_vector(MASTER_ADDRESSWIDTH - 1 downto 0);
        SDRAM_Avalon_MM_BE              : out std_logic_vector((MASTER_DATAWIDTH/8) - 1 downto 0);
        SDRAM_Avalon_MM_Read            : out std_logic                     -- Read request
    );
end entity SDRAM_CTRL;

architecture RTL of SDRAM_CTRL is

    

    type t_Command_Status_Regs is array (0 to NUMREGS - 1) of std_logic_vector(REGWIDTH - 1 downto 0);
    signal w_Command_Status_Regs        : t_Command_Status_Regs;        -- Command and Status Registers (CSR) for custom logic
    
    signal START_BYTE                   : std_logic_vector(31 downto 0) := X"00000001";

    signal r_FIFO_Write_EN              : std_logic;
    signal SDRAM_Avalon_MM_Address_cld  : std_logic_vector(MASTER_ADDRESSWIDTH - 1 downto 0);

    type t_State_Type is (s_Idle, s_Receive, s_Cleanup);
    signal r_State                      : t_State_Type;
    signal r_current_state              : t_State_Type;

    signal Internal_Address             : std_logic_vector(MASTER_ADDRESSWIDTH - 1 downto 0);
    signal Base_Address                 : std_logic_vector(MASTER_ADDRESSWIDTH - 1 downto 0);
    signal Data_Counter                 : integer := 0;

begin

    p_Clocked : process(SDRAM_Clk, SDRAM_Rst_n)
    begin

        if SDRAM_Rst_n = '0' then
            r_Current_State             <= s_Idle;
            -- Default Reset Values
            SDRAM_Avalon_MM_Address_cld <= (others => '0');
            SDRAM_Avalon_MM_Read        <= '0';
            SDRAM_Avalon_MM_BE          <= (others => '0');
            Internal_Address            <= (others => '0');
            Base_Address                <= (others => '0');
            r_FIFO_Write_EN             <= '0';
            Data_Counter                <= 0;
        elsif rising_edge(SDRAM_Clk) then
            r_current_state             <= r_State;

            if Control_Avalon_MM_Write = '1' then--and Control_Avalon_MM_Address < NUMREGS then   
                w_Command_Status_Regs(to_integer(unsigned(Control_Avalon_MM_Address))) <= Control_Avalon_MM_WriteData;
            else
                if w_Command_Status_Regs(0) /= START_BYTE then
                    SDRAM_Avalon_MM_Address_cld <= (others => '0');
                    SDRAM_Avalon_MM_BE          <= (others => '0');
                    SDRAM_Avalon_MM_Read        <= '0';
                    --w_Command_Status_Regs(0) <= (others => '0');
                    --w_Command_Status_Regs(1) <= (others => '0');
                    --w_Command_Status_Regs(2) <= (others => '0');
                end if;
            end if;

            case r_current_state is
                when s_Idle =>
                    if w_Command_Status_Regs(0) = START_BYTE then
                        if Data_Counter < w_Command_Status_Regs(1) then
                            --Base_Address                <= w_Command_Status_Regs(2);
                            SDRAM_Avalon_MM_Address_cld <= w_Command_Status_Regs(2) + Internal_Address;
                            SDRAM_Avalon_MM_Read        <= '1';
                            SDRAM_Avalon_MM_BE          <= (others => '1');
                        end if;
                    else
                        SDRAM_Avalon_MM_Read        <= '0';
                        SDRAM_Avalon_MM_BE          <= (others => '0');
                        Internal_Address            <= (others => '0');
                        Base_Address                <= (others => '0');
                        Data_Counter                <= 0;
                    end if;

                when s_Receive => 
                    if SDRAM_Avalon_MM_WaitReq = '0' and FIFO_Full = '0' and SDRAM_Avalon_MM_Read_DV = '1' and Data_Counter < w_Command_Status_Regs(1) then
                        SDRAM_Avalon_MM_Read        <= '1';
                        r_FIFO_Write_EN             <= '1';
                        FIFO_Data                   <= SDRAM_Avalon_MM_ReadData;
                        --Internal_Address            <= Internal_Address + "100";
                        SDRAM_Avalon_MM_Address_cld <= SDRAM_Avalon_MM_Address_cld + "100";
                    else
                        r_FIFO_Write_EN <= '0';
                    end if;

                when s_Cleanup =>
                    --Internal_Address                <= Internal_Address + "100";
                    Data_Counter                    <= Data_Counter + 1;
                    r_FIFO_Write_EN                 <= '0';
                    if Data_Counter < w_Command_Status_Regs(1) then
                        --Base_Address                <= w_Command_Status_Regs(2);
                        --SDRAM_Avalon_MM_Address_cld <= w_Command_Status_Regs(2) + Internal_Address;
                        SDRAM_Avalon_MM_Read        <= '1';
                        SDRAM_Avalon_MM_BE          <= (others => '1');
                    else
                        SDRAM_Avalon_MM_Read        <= '0';
                    end if;
                    
                when others =>
                    NULL;

            end case;
        end if;
    end process;

    -- Next state logic
    -- Combinatorial process:
    p_next_state : process (
        r_current_state,
        w_Command_Status_Regs,
        SDRAM_Avalon_MM_WaitReq,
        FIFO_Full,
        SDRAM_Avalon_MM_Read_DV
    )
    begin

        case r_current_state is
            when s_Idle =>
                if (w_Command_Status_Regs(0) = START_BYTE) then
                    if Data_Counter < w_Command_Status_Regs(1) then
                        --Base_Address    <= w_Command_Status_Regs(2);
                        r_state         <= s_Receive;
                    end if;
                end if;

            when s_Receive =>
                if SDRAM_Avalon_MM_WaitReq = '0' and FIFO_Full = '0' and SDRAM_Avalon_MM_Read_DV = '1' then
                    r_state             <= s_Cleanup;
                end if;

            when s_Cleanup =>
                if Data_Counter < w_Command_Status_Regs(1) then
                    r_state             <= s_Receive;
                else
                    r_state             <= s_Idle;
                end if;
            
            when others =>
                r_state                 <= s_Idle;
        end case;  
    end process p_next_state;

    SDRAM_Avalon_MM_Address <= SDRAM_Avalon_MM_Address_cld;
    FIFO_Write_EN <= r_FIFO_Write_EN;

end architecture RTL;
