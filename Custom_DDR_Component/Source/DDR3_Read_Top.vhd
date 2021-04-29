-------------------------------------------------------------------------------------------------------------------------------
-- Jared Hermans
-------------------------------------------------------------------------------------------------------------------------------
-- Description: There are 3 control registers which can be written to from the HPS. The control register with an offset of 0x08
--              is used to write the start address of memory for the transaction (EX: 0x30000000). The control register 
--              with an offset of 0x04 is used to write the number of transaction (EX: 0x4 will perform 4 32-bit reads).
--              The control register with an offset of 0x00 is to start the transaction. To start the transaction, write 0x1
--              to this address. After the read is completed, you must write 0x00 back to this address to reset the IP or it
--              will not perform another transaction.
--
--              Make sure Avalon Master is connected to f2h_sdram0_data and sdram width in HPS IP is equal to MASTER_DATAWIDTH

--  
-------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity DDR3_Read_Top is
    generic(                -- DO NOT CHANGE THESE VALUES - NOT TESTED
        MASTER_ADDRESSWIDTH                 : integer := 32;  -- Specifies how many addresses the Master can address
        SLAVE_ADDRESSWIDTH                  : integer := 2;   -- Specifies how many addresses the Slave can address
        MASTER_DATAWIDTH                    : integer := 32;  -- Specifies the Data width of SDRAM read
        SLAVE_DATAWIDTH                     : integer := 32;  -- Specifies the Data width of Control Port
        NUMREGS                             : integer := 3;   -- Number of Internal Registers for Custom Logic
        REGWIDTH                            : integer := 32
    );
    port(
        Clk                                 : IN     std_logic;                                         -- AXI Clock
        Rst_n                               : IN     std_logic;
        ---------------- Conduit Ports ----------------
        export_Clk                          : IN     std_logic;                                         -- FIFO Read Clock
        export_aclr                         : IN     std_logic;                                         -- asynchronous clear to FIFO
        export_rdreq                        : IN     std_logic;                                         -- FIFO Read Enable
        export_q                            : OUT    std_logic_vector(127 downto 0);                    -- FIFO Output Data
        export_rdempty                      : OUT    std_logic;                                         -- FIFO Empty
        o_DDR_Transfer_Done                 : out    std_logic;                                         
        ---------------- Avalon MM Slave Control Port Signals ----------------
        Control_Avalon_MM_Address           : IN     std_logic_vector(SLAVE_ADDRESSWIDTH - 1 downto 0);
        Control_Avalon_MM_Write             : IN     std_logic;                                         -- write request from master        
        Control_Avalon_MM_WriteData         : IN     std_logic_vector(SLAVE_DATAWIDTH - 1 downto 0);    -- Data input in response to write request
        Control_Avalon_MM_ReadData          : OUT    std_logic_vector(31 downto 0);
        ---------------- Avalon MM Master SDRAM Signals ----------------
        SDRAM_Clk                           : IN     STD_LOGIC;
        SDRAM_Rst_n                         : IN     std_logic;        
        SDRAM_Avalon_MM_WaitReq             : IN     std_logic;                                         -- Force master to stall transfer
        SDRAM_Avalon_MM_ReadData            : IN     std_logic_vector (MASTER_DATAWIDTH - 1 DOWNTO 0);  -- Data returned from read request
        SDRAM_Avalon_MM_Read_DV             : IN     std_logic;

        SDRAM_Avalon_MM_Address             : OUT    std_logic_vector (MASTER_ADDRESSWIDTH - 1 DOWNTO 0);
        SDRAM_Avalon_MM_Burst_Count         : OUT    std_logic_vector(7 downto 0);
        SDRAM_Avalon_MM_Read                : OUT    std_logic                                          -- Read request
    );
end entity DDR3_Read_Top;

architecture RTL of DDR3_Read_Top is

    signal SDRAM_TO_FIFO_Data               : std_logic_vector(31 downto 0);
    signal SDRAM_TO_FIFO_EN                 : std_logic;
    signal FIFO_TO_SDRAM_Full               : std_logic;

    component FIFO_IP is
	    PORT(
		    aclr		                    : IN  STD_LOGIC  := '0';
		    data		                    : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
		    rdclk		                    : IN  STD_LOGIC ;
		    rdreq		                    : IN  STD_LOGIC ;
		    wrclk		                    : IN  STD_LOGIC ;
		    wrreq		                    : IN  STD_LOGIC ;
		    q		                        : OUT STD_LOGIC_VECTOR (127 DOWNTO 0);
		    rdempty		                    : OUT STD_LOGIC ;
		    wrfull		                    : OUT STD_LOGIC 
	    );
    end component FIFO_IP;

    component SDRAM_CTRL is
        generic(
            MASTER_ADDRESSWIDTH             : integer;          -- Specifies how many addresses the Master can address
            SLAVE_ADDRESSWIDTH              : integer;          -- Specifies how many addresses the Slave needs to be mapped to. log(NUMREGS)
            MASTER_DATAWIDTH                : integer;          -- Specifies the Data width of SDRAM read
            SLAVE_DATAWIDTH                 : integer;          -- Specifies the Data width of Control Port
            NUMREGS                         : integer;          -- Number of Internal Registers for Custom Logic
            REGWIDTH                        : integer           -- Data width for the Internal Registers
        );
        port(
            Clk                             : in  std_logic;
            Rst_n                           : in  std_logic;
            --------------- Exported (conduit) signals ---------------
            FIFO_Full                       : in  std_logic;
            FIFO_Data                       : out std_logic_vector(31 downto 0);
            FIFO_Write_EN                   : out std_logic;
            o_DDR_Transfer_Done             : out std_logic;
            ---------------- Avalon MM Slave Control Port Signals ----------------
            Control_Avalon_MM_Address       : IN  std_logic_vector(SLAVE_ADDRESSWIDTH - 1 downto 0);
            Control_Avalon_MM_Write         : IN  std_logic;                                        -- write request from master        
            Control_Avalon_MM_WriteData     : IN  std_logic_vector(SLAVE_DATAWIDTH - 1 downto 0);   -- Data input in response to write request
            Control_Avalon_MM_ReadData      : OUT std_logic_vector(31 downto 0);
            -------- Avalon MM Master Signals (SDRAM Read Master) ----------------
            SDRAM_Clk                       : in  std_logic;
            SDRAM_Rst_n                     : in  std_logic;
            SDRAM_Avalon_MM_WaitReq         : in  std_logic;                                        -- Force master to stall transfer
            SDRAM_Avalon_MM_ReadData        : in  std_logic_vector(MASTER_DATAWIDTH - 1 downto 0);
            SDRAM_Avalon_MM_Read_DV         : in  std_logic;

            SDRAM_Avalon_MM_Address         : out std_logic_vector(MASTER_ADDRESSWIDTH - 1 downto 0);
            SDRAM_Avalon_MM_Burst_Count     : out std_logic_vector(7 downto 0);
            SDRAM_Avalon_MM_Read            : out std_logic                                         -- Read request
        );
    end component SDRAM_CTRL;

begin

    FIFO_IP_Inst : FIFO_IP
	    PORT map(
		    aclr		=> export_aclr,
		    data		=> SDRAM_TO_FIFO_Data,
		    rdclk		=> export_Clk,
		    rdreq		=> export_rdreq,
		    wrclk		=> SDRAM_Clk,
		    wrreq		=> SDRAM_TO_FIFO_EN,
		    q		    => export_q,
		    rdempty		=> export_rdempty,
		    wrfull		=> FIFO_TO_SDRAM_Full
	    );

    SDRAM_CTRL_Inst : SDRAM_CTRL
        generic map(
            MASTER_ADDRESSWIDTH             => MASTER_ADDRESSWIDTH,
            SLAVE_ADDRESSWIDTH              => SLAVE_ADDRESSWIDTH,
            MASTER_DATAWIDTH                => MASTER_DATAWIDTH,
            SLAVE_DATAWIDTH                 => SLAVE_DATAWIDTH,
            NUMREGS                         => NUMREGS,
            REGWIDTH                        => REGWIDTH
        )
        port map(
            Clk                             => Clk,
            Rst_n                           => Rst_n,
            --------------- Exported (conduit) signals ---------------

            FIFO_Full                       => FIFO_TO_SDRAM_Full,
            FIFO_Data                       => SDRAM_TO_FIFO_Data,
            FIFO_Write_EN                   => SDRAM_TO_FIFO_EN,
            o_DDR_Transfer_Done             => o_DDR_Transfer_Done,

            ---------------- Avalon MM Slave Control Port Signals ----------------
            Control_Avalon_MM_Address       => Control_Avalon_MM_Address,
            Control_Avalon_MM_Write         => Control_Avalon_MM_Write,    
            Control_Avalon_MM_WriteData     => Control_Avalon_MM_WriteData,
            Control_Avalon_MM_ReadData      => Control_Avalon_MM_ReadData,

            ---------------- Avalon MM Master Signals (SDRAM Read Master) ----------------
            SDRAM_Clk                       => SDRAM_Clk,
            SDRAM_Rst_n                     => SDRAM_Rst_n,
            SDRAM_Avalon_MM_WaitReq         => SDRAM_Avalon_MM_WaitReq,
            SDRAM_Avalon_MM_ReadData        => SDRAM_Avalon_MM_ReadData,
            SDRAM_Avalon_MM_Read_DV         => SDRAM_Avalon_MM_Read_DV,

            SDRAM_Avalon_MM_Address         => SDRAM_Avalon_MM_Address,
            SDRAM_Avalon_MM_Burst_Count     => SDRAM_Avalon_MM_Burst_Count,
            SDRAM_Avalon_MM_Read            => SDRAM_Avalon_MM_Read
        );

end architecture RTL;