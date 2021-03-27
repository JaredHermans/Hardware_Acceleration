library ieee;
use ieee.std_logic_1164.all;

entity DDR_TB is
end entity DDR_TB;

architecture BEHAVE of DDR_TB is

    constant c_CLK_PERIOD               : time := 20 ns;    -- 50 MHz Clock
    constant c_SDRAM_PERIOD             : time := 10 ns;

    signal r_Clk                        : std_logic := '1';
    signal r_SDRAM_Clk                  : std_logic := '1';
    signal Rst_n                        : std_logic := '1';

    signal r_FIFO_aclr                  : std_logic := '0';
    signal r_FIFO_Read_EN               : std_logic := '1';
    signal w_FIFO_Data                  : std_logic_vector(127 downto 0);
    signal w_FIFO_Empty                 : std_logic;

    signal Control_Avalon_MM_Address    : std_logic_vector(1 downto 0) := (others => '0');
    signal Control_Avalon_MM_Write      : std_logic := '0';
    signal Control_Avalon_MM_WriteData  : std_logic_vector(31 downto 0) := (others => '0');

    signal SDRAM_Avalon_MM_WaitReq      : std_logic := '0';
    signal SDRAM_Avalon_MM_ReadData     : std_logic_vector(31 downto 0) := (others => '0');
    signal SDRAM_Avalon_MM_Read_DV      : std_logic := '0';

    signal w_SDRAM_Avalon_MM_Address    : std_logic_vector(31 downto 0);
    signal w_SDRAM_Avalon_MM_BE         : std_logic_vector(3 downto 0);
    signal w_SDRAM_Avalon_MM_Read       : std_logic;

    procedure Avalon_MM_Slave_Setup(
        signal MM_Address_Slave : out std_logic_vector(1 downto 0);
        signal MM_Write         : out std_logic;
        signal MM_Write_Data    : out std_logic_vector(31 downto 0)
    ) is
    begin
        wait until rising_edge(r_Clk);
        MM_Address_Slave    <= "10";-- Address of slave to write Address of DDR for master
        MM_Write            <= '1';
        MM_Write_Data <= X"08000000";
        wait until rising_edge(r_Clk);
        MM_Address_Slave    <= "01";-- Address of slave to write number of transactions
        MM_Write_Data <= X"00000004";
        wait until rising_edge(r_Clk);
        MM_Address_Slave    <= "00";-- Address of slave to start transaction
        MM_Write_Data <= X"00000001";
        wait until rising_edge(r_Clk);
        MM_Write  <= '0';
        --wait until rising_edge(r_Clk);
    end procedure Avalon_MM_Slave_Setup;

    procedure Avalon_MM_Master_Setup(
        MM_Address              : in  std_logic_vector(31 downto 0);
        MM_BE                   : in  std_logic_vector(3 downto 0);
        MM_Read                 : in  std_logic;
        signal MM_WaitReq       : out std_logic;
        signal MM_ReadData      : out std_logic_vector(31 downto 0);
        signal MM_Read_DV       : out std_logic
    ) is
    begin
        for i in 0 to 20 loop 
            if MM_Read = '1' and MM_BE = "1111" then          
                if MM_Address = X"08000008" then
                    MM_WaitReq      <= '1';
                    MM_ReadData     <= X"FFFFFFFF";
                    MM_Read_DV      <='0';
                    wait until rising_edge(r_SDRAM_Clk);
                    wait until rising_edge(r_SDRAM_Clk);
                    MM_WaitReq      <= '0';
                    MM_Read_DV      <= '1';
                    wait until rising_edge(r_SDRAM_Clk);
                    MM_Read_DV      <= '0';
                elsif MM_Address = X"08000004" then
                    --wait until rising_edge(r_SDRAM_Clk);
                    MM_WaitReq      <= '0';
                    MM_ReadData     <= X"55555555";
                    MM_Read_DV      <= '1';
                    wait until rising_edge(r_SDRAM_Clk);
                elsif MM_Address = X"08000000" then
                    --wait until rising_edge(r_SDRAM_Clk);
                    MM_WaitReq      <= '0';
                    MM_ReadData     <= X"12345678";
                    MM_Read_DV      <= '1';
                    --wait until rising_edge(r_SDRAM_Clk);
                    --MM_Read_DV      <= '0';
                    wait until rising_edge(r_SDRAM_Clk); 
                else
                    MM_Read_DV      <= '0';
                end if;
            else
                MM_Read_DV          <= '0';
            end if;
            MM_Read_DV              <= '0';
            wait until rising_edge(r_SDRAM_Clk);
        end loop;
    end procedure Avalon_MM_Master_Setup;

begin

    DDR3_Read_Top_Inst : entity work.DDR3_Read_Top  
        generic map(
            MASTER_ADDRESSWIDTH           => 32,  -- Specifies how many addresses the Master can address
            SLAVE_ADDRESSWIDTH            => 2,   -- Specifies how many addresses the Slave can address
            MASTER_DATAWIDTH              => 32,  -- Specifies the Data width of SDRAM read
            SLAVE_DATAWIDTH               => 32,  -- Specifies the Data width of Control Port
            NUMREGS                       => 4,   -- Number of Internal Registers for Custom Logic
            REGWIDTH                      => 32
        )
        port map(
            Clk                           => r_Clk,
            Rst_n                         => Rst_n,
            ---------------- Conduit Ports ----------------
            export_aclr                   => r_FIFO_aclr,
            export_rdreq                  => r_FIFO_Read_EN,
            export_q                      => w_FIFO_Data,
            export_rdempty                => w_FIFO_Empty,
            ---------------- Avalon MM Slave Control Port Signals ----------------
            Control_Avalon_MM_Address     => Control_Avalon_MM_Address,
            --Control_Avalon_MM_CS          : IN     std_logic;
            Control_Avalon_MM_Write       => Control_Avalon_MM_Write,       -- write request from master        
            Control_Avalon_MM_WriteData   => Control_Avalon_MM_WriteData,   -- Data input in response to write request
            ---------------- Avalon MM Master SDRAM Signals ----------------
            SDRAM_Clk                     => r_SDRAM_Clk,
            SDRAM_Rst_n                   => Rst_n,        
            SDRAM_Avalon_MM_WaitReq       => SDRAM_Avalon_MM_WaitReq,       -- Force master to stall transfer
            SDRAM_Avalon_MM_ReadData      => SDRAM_Avalon_MM_ReadData,      -- Data returned from read request
            SDRAM_Avalon_MM_Read_DV       => SDRAM_Avalon_MM_Read_DV,
    
            SDRAM_Avalon_MM_Address       => w_SDRAM_Avalon_MM_Address,
            SDRAM_Avalon_MM_BE            => w_SDRAM_Avalon_MM_BE,          -- Data width / 8
            SDRAM_Avalon_MM_Read          => w_SDRAM_Avalon_MM_Read         -- Read request
        );

    r_Clk <= not r_Clk after c_CLK_PERIOD / 2;
    r_SDRAM_Clk <= not r_SDRAM_Clk after c_SDRAM_PERIOD / 2;

    process 
    begin
        Avalon_MM_Slave_Setup(  Control_Avalon_MM_Address,
                                Control_Avalon_MM_Write,
                                Control_Avalon_MM_WriteData);
        wait for c_CLK_PERIOD;    
        Avalon_MM_Master_Setup( w_SDRAM_Avalon_MM_Address,
                                w_SDRAM_Avalon_MM_BE,
                                w_SDRAM_Avalon_MM_Read,
                                SDRAM_Avalon_MM_WaitReq,
                                SDRAM_Avalon_MM_ReadData,
                                SDRAM_Avalon_MM_Read_DV);

        SDRAM_Avalon_MM_ReadData <= X"20505050";
        wait for 8*c_CLK_PERIOD;
        SDRAM_Avalon_MM_ReadData <= X"50505050";
        wait for c_CLK_PERIOD;

        assert false report "Test Complete" severity failure;
    end process;
end architecture BEHAVE;