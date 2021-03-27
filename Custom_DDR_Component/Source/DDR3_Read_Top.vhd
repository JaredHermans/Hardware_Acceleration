library ieee;
use ieee.std_logic_1164.all;

entity DDR3_Read_Top is
    generic(
        MASTER_ADDRESSWIDTH           : integer := 32;  -- Specifies how many addresses the Master can address
        SLAVE_ADDRESSWIDTH            : integer := 2;   -- Specifies how many addresses the Slave can address
        MASTER_DATAWIDTH              : integer := 32;  -- Specifies the Data width of SDRAM read
        SLAVE_DATAWIDTH               : integer := 32;  -- Specifies the Data width of Control Port
        NUMREGS                       : integer := 4;   -- Number of Internal Registers for Custom Logic
        REGWIDTH                      : integer := 32
    );
    port(
        Clk                           : IN     std_logic;
        Rst_n                         : IN     std_logic;
        ---------------- Conduit Ports ----------------
        export_aclr                   : IN     std_logic;   -- asynchronous clear to FIFO
        export_rdreq                  : IN     std_logic;
        export_q                      : OUT    std_logic_vector(4*MASTER_DATAWIDTH - 1 downto 0);
        export_rdempty                : OUT    std_logic;
        ---------------- Avalon MM Slave Control Port Signals ----------------
        Control_Avalon_MM_Address     : IN     std_logic_vector(SLAVE_ADDRESSWIDTH - 1 downto 0);
        --Control_Avalon_MM_CS          : IN     std_logic;
        Control_Avalon_MM_Write       : IN     std_logic;                                   -- write request from master        
        Control_Avalon_MM_WriteData   : IN     std_logic_vector(SLAVE_DATAWIDTH - 1 downto 0);  -- Data input in response to write request
        ---------------- Avalon MM Master SDRAM Signals ----------------
        SDRAM_Clk                     : IN     STD_LOGIC;
        SDRAM_Rst_n                   : IN     std_logic;        
        SDRAM_Avalon_MM_WaitReq       : IN     std_logic;                                   -- Force master to stall transfer
        SDRAM_Avalon_MM_ReadData      : IN     std_logic_vector (MASTER_DATAWIDTH - 1 DOWNTO 0);  -- Data returned from read request
        SDRAM_Avalon_MM_Read_DV       : IN     std_logic;

        SDRAM_Avalon_MM_Address       : OUT    std_logic_vector (MASTER_ADDRESSWIDTH - 1 DOWNTO 0);
        SDRAM_Avalon_MM_BE            : OUT    std_logic_vector ((MASTER_DATAWIDTH/8) - 1 DOWNTO 0); -- Data width / 8
        SDRAM_Avalon_MM_Read          : OUT    std_logic                                    -- Read request
    );
end entity DDR3_Read_Top;

architecture RTL of DDR3_Read_Top is

    signal SDRAM_TO_FIFO_Data           : std_logic_vector(31 downto 0);
    signal SDRAM_TO_FIFO_EN             : std_logic;
    signal FIFO_TO_SDRAM_Full           : std_logic;


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
    end component SDRAM_CTRL;

begin

    FIFO_IP_Inst : FIFO_IP
	    PORT map(
		    aclr		=> export_aclr,
		    data		=> SDRAM_TO_FIFO_Data,
		    rdclk		=> Clk,
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
            -- Inputs
            FIFO_Full                       => FIFO_TO_SDRAM_Full,
            -- Outputs
            FIFO_Data                       => SDRAM_TO_FIFO_Data,
            FIFO_Write_EN                   => SDRAM_TO_FIFO_EN,
            ---------------- Avalon MM Slave Control Port Signals ----------------
            Control_Avalon_MM_Address       => Control_Avalon_MM_Address,
            --Control_Avalon_MM_CS            : IN     std_logic;
            Control_Avalon_MM_Write         => Control_Avalon_MM_Write,    
            Control_Avalon_MM_WriteData     => Control_Avalon_MM_WriteData,
            -------- Avalon MM Master Signals (SDRAM Read Master) ----------------
            SDRAM_Clk                       => SDRAM_Clk,
            SDRAM_Rst_n                     => SDRAM_Rst_n,
            SDRAM_Avalon_MM_WaitReq         => SDRAM_Avalon_MM_WaitReq,
            SDRAM_Avalon_MM_ReadData        => SDRAM_Avalon_MM_ReadData,
            SDRAM_Avalon_MM_Read_DV         => SDRAM_Avalon_MM_Read_DV,

            SDRAM_Avalon_MM_Address         => SDRAM_Avalon_MM_Address,
            SDRAM_Avalon_MM_BE              => SDRAM_Avalon_MM_BE,
            SDRAM_Avalon_MM_Read            => SDRAM_Avalon_MM_Read
        );

end architecture RTL;