-------------------------------------------------------------------------------------------------------------------------------
-- Jared Hermans
-------------------------------------------------------------------------------------------------------------------------------
-- Description: This testbench uses procedures to verify the IP. The Avalon_MM_Slave_Setup procedure writes the address, number
--              of transactions and the start bit into the control registers of the IP. The Avalon_MM_Master_Setup provides
--              the read data to the IP. The Avalon_MM_Slave_Reset resets the IP so it can be used again.
--
--              To run the testbench and see the waveforms open the Modelsim project file (.mpf) in 
--              /Custom_DDR_Component_32_Bit/TB and execute "do run.do" in the command line.
--  
-------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

entity DDR_TB2 is
end entity DDR_TB2;

architecture BEHAVE of DDR_TB2 is

    constant c_CLK_PERIOD               : time := 10 ns;    -- 100 MHz Clock (AXI Clock)
    constant c_SDRAM_PERIOD             : time := 5 ns;     -- 200 MHz Clock (SDRAM Clock)
    constant c_FPGA_PERIOD              : time := 20 ns;    -- 50 MHz Clock (FPGA Clock)

    signal r_Clk                        : std_logic := '1'; -- Set initial value of all clocks to 1 
    signal r_SDRAM_Clk                  : std_logic := '1'; -- so rising edge sync
    signal r_FPGA_Clk                   : std_logic := '1';
    signal Rst_n                        : std_logic := '1';
    signal SDRAM_Rst_n 			        : std_logic := '1';

    signal r_FIFO_aclr                  : std_logic := '0';
    signal r_FIFO_Read_EN               : std_logic := '1';
    signal w_FIFO_Data                  : std_logic_vector(127 downto 0);
    signal w_FIFO_Empty                 : std_logic;
    signal w_DDR_Transfer_Done          : std_logic;

    signal Control_Avalon_MM_Address    : std_logic_vector(1 downto 0) := (others => '0');
    signal Control_Avalon_MM_Write      : std_logic := '0';
    signal Control_Avalon_MM_WriteData  : std_logic_vector(31 downto 0) := (others => '0');
    signal w_Control_Avalon_MM_ReadData : std_logic_vector(31 downto 0);

    signal SDRAM_Avalon_MM_WaitReq      : std_logic := '0';
    signal SDRAM_Avalon_MM_ReadData     : std_logic_vector(31 downto 0) := (others => '0');
    signal SDRAM_Avalon_MM_Read_DV      : std_logic := '0';

    signal w_SDRAM_Avalon_MM_Address    : std_logic_vector(31 downto 0);
    signal w_SDRAM_Avalon_MM_Burst_Count: std_logic_vector(7 downto 0);
    signal w_SDRAM_Avalon_MM_Read       : std_logic;
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
    -- Reset IP to perform another read
    procedure Avalon_MM_Slave_Reset(
        signal MM_Address_Slave         : out std_logic_vector(1 downto 0);
        signal MM_Write                 : out std_logic;
        signal MM_Write_Data            : out std_logic_vector(31 downto 0)
    ) is
    begin
        wait until rising_edge(r_Clk);
        MM_Write                        <= '1';
        MM_Address_Slave                <= "00";
        MM_Write_Data                   <= X"00000000";
        wait until rising_edge(r_Clk);
        MM_Write                        <= '0';
    end procedure;
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
    -- Set up Control Registers of the IP
    procedure Avalon_MM_Slave_Setup(
        i                               : in  integer;
        addr                            : in  std_logic_vector(31 downto 0);
        signal MM_Address_Slave         : out std_logic_vector(1 downto 0);
        signal MM_Write                 : out std_logic;
        signal MM_Write_Data            : out std_logic_vector(31 downto 0)
    ) is
    begin
        wait until rising_edge(r_Clk);
        MM_Address_Slave                <= "10";    -- Address of slave to write Address of DDR for master
        MM_Write                        <= '1';
        MM_Write_Data <= addr;                      -- Value goes into control register in SDRAM_CTRL for initial read address
        wait until rising_edge(r_Clk);
        MM_Address_Slave                <= "01";    -- Address of slave to write number of transactions
        MM_Write_Data <= std_logic_vector(to_unsigned(i,32));   
        wait until rising_edge(r_Clk);
        MM_Address_Slave                <= "00";    -- Address of slave to start transaction
        MM_Write_Data <= X"00000001";               -- Go bit
        wait until rising_edge(r_Clk);
        MM_Write                        <= '0';
        wait until rising_edge(r_SDRAM_Clk);
    end procedure Avalon_MM_Slave_Setup;
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
    procedure Avalon_MM_Master_Setup(
        i                               : in  integer;
        addr                            : in  std_logic_vector(31 downto 0);
        --MM_Address                    : in  std_logic_vector(31 downto 0);
        --MM_Read                       : in  std_logic;
        signal MM_WaitReq               : out std_logic;
        signal MM_ReadData              : out std_logic_vector(31 downto 0);
        signal MM_Read_DV               : out std_logic
    ) is
    begin
        MM_WaitReq                  <= '0';
        MM_Read_DV                  <= '1';
        for j in 0 to i - 1 loop
            MM_ReadData             <= std_logic_vector(to_unsigned(j+1,32));
            if j = 5 or j = 9 then  -- Test wait request
                MM_WaitReq          <= '1';
                wait until rising_edge(r_SDRAM_Clk);
                wait until rising_edge(r_SDRAM_Clk);
                MM_WaitReq          <= '0';
            end if;
            wait until rising_edge(r_SDRAM_Clk);
        end loop;
    end procedure Avalon_MM_Master_Setup;
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
begin

    DDR3_Read_Top_Inst : entity work.DDR3_Read_Top  
        generic map(
            MASTER_ADDRESSWIDTH           => 32,  -- Specifies how many addresses the Master can address
            SLAVE_ADDRESSWIDTH            => 2,   -- Specifies how many addresses the Slave can address
            MASTER_DATAWIDTH              => 32,  -- Specifies the Data width of SDRAM read
            SLAVE_DATAWIDTH               => 32,  -- Specifies the Data width of Control Port
            NUMREGS                       => 3,   -- Number of Internal Registers for Custom Logic
            REGWIDTH                      => 32
        )
        port map(
            Clk                           => r_Clk,
            Rst_n                         => Rst_n,
            ---------------- Conduit Ports ----------------
            export_Clk                    => r_FPGA_Clk,
            export_aclr                   => r_FIFO_aclr,
            export_rdreq                  => r_FIFO_Read_EN,
            export_q                      => w_FIFO_Data,
            export_rdempty                => w_FIFO_Empty,

            o_DDR_Transfer_Done           => w_DDR_Transfer_Done,
            ---------------- Avalon MM Slave Control Port Signals ----------------
            Control_Avalon_MM_Address     => Control_Avalon_MM_Address,
            Control_Avalon_MM_Write       => Control_Avalon_MM_Write,       -- write request from master        
            Control_Avalon_MM_WriteData   => Control_Avalon_MM_WriteData,   -- Data input in response to write request
            Control_Avalon_MM_ReadData    => w_Control_Avalon_MM_ReadData,
            ---------------- Avalon MM Master SDRAM Signals ----------------
            SDRAM_Clk                     => r_SDRAM_Clk,
            SDRAM_Rst_n                   => SDRAM_Rst_n,        
            SDRAM_Avalon_MM_WaitReq       => SDRAM_Avalon_MM_WaitReq,       -- Force master to stall transfer
            SDRAM_Avalon_MM_ReadData      => SDRAM_Avalon_MM_ReadData,      -- Data returned from read request
            SDRAM_Avalon_MM_Read_DV       => SDRAM_Avalon_MM_Read_DV,
    
            SDRAM_Avalon_MM_Address       => w_SDRAM_Avalon_MM_Address,
            SDRAM_Avalon_MM_Burst_Count   => w_SDRAM_Avalon_MM_Burst_Count,
            SDRAM_Avalon_MM_Read          => w_SDRAM_Avalon_MM_Read         -- Read request
        );
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
    r_Clk                       <= not r_Clk after c_CLK_PERIOD / 2;
    r_SDRAM_Clk                 <= not r_SDRAM_Clk after c_SDRAM_PERIOD / 2;
    r_FPGA_Clk                  <= not r_FPGA_Clk after c_FPGA_PERIOD / 2;
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
    process 
        variable addr           : std_logic_vector(31 downto 0);
        variable i              : integer;
    begin

	    wait for c_CLK_PERIOD;
	    Rst_n                   <= '0';
        SDRAM_Rst_n             <= '0';

        i                       := 16;
        addr                    := X"00100000";

        Avalon_MM_Slave_Setup(  i,
                                addr,
                                Control_Avalon_MM_Address,
                                Control_Avalon_MM_Write,
                                Control_Avalon_MM_WriteData);

        Avalon_MM_Master_Setup( i,
                                addr,
                                --w_SDRAM_Avalon_MM_Address,    -- Check correct value in waveform
                                --w_SDRAM_Avalon_MM_Read,       -- Check in waveform
                                SDRAM_Avalon_MM_WaitReq,
                                SDRAM_Avalon_MM_ReadData,
                                SDRAM_Avalon_MM_Read_DV);


        wait for 4*c_CLK_PERIOD;

        Avalon_MM_Slave_Reset(  Control_Avalon_MM_Address,
                                Control_Avalon_MM_Write,
                                Control_Avalon_MM_WriteData);
        
        i                       := 256;
        addr                    := X"30000000";

        Avalon_MM_Slave_Setup(  i,
                                addr,
                                Control_Avalon_MM_Address,
                                Control_Avalon_MM_Write,
                                Control_Avalon_MM_WriteData);

        Avalon_MM_Master_Setup( i,
                                addr,
                                SDRAM_Avalon_MM_WaitReq,
                                SDRAM_Avalon_MM_ReadData,
                                SDRAM_Avalon_MM_Read_DV);

        wait for 20*c_CLK_PERIOD;

        assert false report "Test Complete" severity failure;
    end process;
end architecture BEHAVE;