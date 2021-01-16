library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library altera;
use altera.altera_syn_attributes.all;

entity MULT_ADDER_QSYS is
    Port (
	CLOCK50 					: in    STD_LOGIC; -- FPGA CLOCK
	CLOCK0 						: in    STD_LOGIC; -- HPS CLOCK
	-- HPS pin declarastion
	-- DDR3
	HPS_DRAM_MA                            		: out   STD_LOGIC_VECTOR(13 downto 0);
	HPS_DRAM_BA                            		: out   STD_LOGIC_VECTOR(2 downto 0);
	HPS_DRAM_nMCS                          		: out   STD_LOGIC;
	HPS_DRAM_nCAS                          		: out   STD_LOGIC;
	HPS_DRAM_nRAS                          		: out   STD_LOGIC;
	HPS_DRAM_MCKE                          		: out   STD_LOGIC;
	HPS_DRAM_nMWE                                   : out   STD_LOGIC;
	HPS_DRAm_nRESET                        		: out   STD_LOGIC;
	HPS_DRAM_SDCLK_0_P                     		: out   STD_LOGIC;
	HPS_DRAM_SDCLK_0_N				: out   STD_LOGIC;
	HPS_DRAM_MODT                          		: out   STD_LOGIC;  
	HPS_DRAM_RZQ                           		: in    STD_LOGIC;
	HPS_DRAM_MDQ                           		: inout STD_LOGIC_VECTOR(15 downto 0);
	HPS_DRAM_MDM                           		: out   STD_LOGIC_VECTOR(1 downto 0);
	HPS_DRAM_DQS0_P                        		: inout STD_LOGIC_VECTOR(1 downto 0);
	HPS_DRAM_DQS0_N                        		: inout STD_LOGIC_VECTOR(1 downto 0);
	
	-- UART0
	HPS_3V3_UART0_TX                       		: out   STD_LOGIC;
	HPS_3V3_UART0_RX                       		: in    STD_LOGIC;
			
	-- SD
	HPS_3V3_SDMMC_CLK                      		: out   STD_LOGIC;
	HPS_3V3_SDMMC_CMD                      		: inout STD_LOGIC;
	HPS_3V3_SDMMC_D0                       		: inout STD_LOGIC;
	HPS_3V3_SDMMC_D1                       		: inout STD_LOGIC;
	HPS_3V3_SDMMC_D2                       		: inout STD_LOGIC;
	HPS_3V3_SDMMC_D3                       		: inout STD_LOGIC;
				
	-- I2C
	HPS_3V3_I2C0_SCL                           	: inout STD_LOGIC;
	HPS_3V3_I2C0_SDA                           	: inout STD_LOGIC;
				
        -- CAN
	HPS_3V3_CAN0_TX                            	: out   STD_LOGIC;
	HPS_3V3_CAN0_RX                            	: in    STD_LOGIC;

	-- EMAC1
	HPS_3V3_EMAC0_RGMII_TXD0                   	: out   STD_LOGIC;
	HPS_3V3_EMAC0_RGMII_TXD1                   	: out   STD_LOGIC;
	HPS_3V3_EMAC0_RGMII_TXD2                   	: out   STD_LOGIC;
	HPS_3V3_EMAC0_RGMII_TXD3                   	: out   STD_LOGIC;
			  
	HPS_3V3_EMAC0_RGMII_TX_CLK                 	: out   STD_LOGIC;
	HPS_3V3_EMAC0_RGMII_TX_CTL                 	: out   STD_LOGIC;
			  
	HPS_3V3_EMAC0_RGMII_RXD0                   	: in    STD_LOGIC;
	HPS_3V3_EMAC0_RGMII_RXD1                   	: in    STD_LOGIC;
	HPS_3V3_EMAC0_RGMII_RXD2                   	: in    STD_LOGIC;
	HPS_3V3_EMAC0_RGMII_RXD3                   	: in    STD_LOGIC;
			  
	HPS_3V3_EMAC0_RGMII_RX_CLK                 	: in    STD_LOGIC;
	HPS_3V3_EMAC0_RGMII_RX_CTL                 	: in    STD_LOGIC;
			  
	HPS_3V3_EMAC0_RGMII_MDC                    	: out   STD_LOGIC;
	HPS_3V3_EMAC0_RGMII_MDIO                   	: inout STD_LOGIC;				

	-- USB
	HPS_3V3_USB1_D0                        		: inout STD_LOGIC;
    	HPS_3V3_USB1_D1                        		: inout STD_LOGIC;
	HPS_3V3_USB1_D2                        		: inout STD_LOGIC;
	HPS_3V3_USB1_D3                        		: inout STD_LOGIC;
        HPS_3V3_USB1_D4                        		: inout STD_LOGIC;
        HPS_3V3_USB1_D5                        		: inout STD_LOGIC;
	HPS_3V3_USB1_D6                       		: inout STD_LOGIC;
	HPS_3V3_USB1_D7                        		: inout STD_LOGIC;
	HPS_3V3_USB1_CLK                       		: in    STD_LOGIC;
	HPS_3V3_USB1_STP                       		: out   STD_LOGIC;
	HPS_3V3_USB1_DIR                       		: in    STD_LOGIC;
	HPS_3V3_USB1_NXT                       		: in    STD_LOGIC
      );				
end entity MULT_ADDER_QSYS;

architecture RTL of MULT_ADDER_QSYS is

	signal w_Result 	: std_logic_vector(63 downto 0);

	component MULT_ADDER5 is
		port(
			i_Clk_HPS 			: in  std_logic;
			i_Clk_FPGA 			: in  std_logic;
			
			i_Dataa_0 			: in  std_logic_vector(63 downto 0);
			i_Datab_0 			: in  std_logic_vector(63 downto 0);
			
			i_Write_EN 			: in  std_logic;
			i_aclr 				: in  std_logic;
			
			o_Full	 			: out std_logic;
			o_Result 			: out std_logic_vector(63 downto 0);
			o_Result_x 			: out std_logic_vector(63 downto 0);
			o_Result_y 			: out std_logic_vector(63 downto 0)
		);
	end component MULT_ADDER5;
	
	
	 component QSYS is
        port (
            memory_mem_a                    : out   std_logic_vector(13 downto 0);                    -- mem_a
            memory_mem_ba                   : out   std_logic_vector(2 downto 0);                     -- mem_ba
            memory_mem_ck                   : out   std_logic;                                        -- mem_ck
            memory_mem_ck_n                 : out   std_logic;                                        -- mem_ck_n
            memory_mem_cke                  : out   std_logic;                                        -- mem_cke
            memory_mem_cs_n                 : out   std_logic;                                        -- mem_cs_n
            memory_mem_ras_n                : out   std_logic;                                        -- mem_ras_n
            memory_mem_cas_n                : out   std_logic;                                        -- mem_cas_n
            memory_mem_we_n                 : out   std_logic;                                        -- mem_we_n
            memory_mem_reset_n              : out   std_logic;                                        -- mem_reset_n
            memory_mem_dq                   : inout std_logic_vector(15 downto 0) := (others => 'X'); -- mem_dq
            memory_mem_dqs                  : inout std_logic_vector(1 downto 0)  := (others => 'X'); -- mem_dqs
            memory_mem_dqs_n                : inout std_logic_vector(1 downto 0)  := (others => 'X'); -- mem_dqs_n
            memory_mem_odt                  : out   std_logic;                                        -- mem_odt
            memory_mem_dm                   : out   std_logic_vector(1 downto 0);                     -- mem_dm
            memory_oct_rzqin                : in    std_logic                     := 'X';             -- oct_rzqin
            hps_io_hps_io_emac1_inst_TX_CLK : out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
            hps_io_hps_io_emac1_inst_TXD0   : out   std_logic;                                        -- hps_io_emac1_inst_TXD0
            hps_io_hps_io_emac1_inst_TXD1   : out   std_logic;                                        -- hps_io_emac1_inst_TXD1
            hps_io_hps_io_emac1_inst_TXD2   : out   std_logic;                                        -- hps_io_emac1_inst_TXD2
            hps_io_hps_io_emac1_inst_TXD3   : out   std_logic;                                        -- hps_io_emac1_inst_TXD3
            hps_io_hps_io_emac1_inst_RXD0   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
            hps_io_hps_io_emac1_inst_MDIO   : inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
            hps_io_hps_io_emac1_inst_MDC    : out   std_logic;                                        -- hps_io_emac1_inst_MDC
            hps_io_hps_io_emac1_inst_RX_CTL : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
            hps_io_hps_io_emac1_inst_TX_CTL : out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
            hps_io_hps_io_emac1_inst_RX_CLK : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
            hps_io_hps_io_emac1_inst_RXD1   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
            hps_io_hps_io_emac1_inst_RXD2   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
            hps_io_hps_io_emac1_inst_RXD3   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
            hps_io_hps_io_sdio_inst_CMD     : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
            hps_io_hps_io_sdio_inst_D0      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
            hps_io_hps_io_sdio_inst_D1      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
            hps_io_hps_io_sdio_inst_CLK     : out   std_logic;                                        -- hps_io_sdio_inst_CLK
            hps_io_hps_io_sdio_inst_D2      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
            hps_io_hps_io_sdio_inst_D3      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
            hps_io_hps_io_usb1_inst_D0      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
            hps_io_hps_io_usb1_inst_D1      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
            hps_io_hps_io_usb1_inst_D2      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
            hps_io_hps_io_usb1_inst_D3      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
            hps_io_hps_io_usb1_inst_D4      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
            hps_io_hps_io_usb1_inst_D5      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
            hps_io_hps_io_usb1_inst_D6      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
            hps_io_hps_io_usb1_inst_D7      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
            hps_io_hps_io_usb1_inst_CLK     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
            hps_io_hps_io_usb1_inst_STP     : out   std_logic;                                        -- hps_io_usb1_inst_STP
            hps_io_hps_io_usb1_inst_DIR     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
            hps_io_hps_io_usb1_inst_NXT     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
            hps_io_hps_io_uart0_inst_RX     : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
            hps_io_hps_io_uart0_inst_TX     : out   std_logic;                                        -- hps_io_uart0_inst_TX
            hps_io_hps_io_i2c0_inst_SDA     : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SDA
            hps_io_hps_io_i2c0_inst_SCL     : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SCL
            hps_io_hps_io_can0_inst_RX      : in    std_logic                     := 'X';             -- hps_io_can0_inst_RX
            hps_io_hps_io_can0_inst_TX      : out   std_logic;                                        -- hps_io_can0_inst_TX
            aclr_external_connection_export : out   std_logic;                                        -- export
            xy0_external_connection_export  : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
            xy1_external_connection_export  : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
            clk_clk                         : in    std_logic                     := 'X'              -- clk
        );
    end component QSYS;

	
begin

	QSYS_Inst : QSYS
		port map(
			-- HPS DDR3
			memory_mem_a                     => HPS_DRAM_MA,
			memory_mem_ba                    => HPS_DRAM_BA,
			memory_mem_ck                    => HPS_DRAM_SDCLK_0_P,
			memory_mem_ck_n                  => HPS_DRAM_SDCLK_0_N,
			memory_mem_cke                   => HPS_DRAM_MCKE,
			memory_mem_cs_n                  => HPS_DRAM_nMCS,
			memory_mem_ras_n                 => HPS_DRAM_nRAS,
			memory_mem_cas_n                 => HPS_DRAM_nCAS,
			memory_mem_we_n                  => HPS_DRAM_nMWE,
			memory_mem_reset_n               => HPS_DRAM_nRESET,
			memory_mem_dq                    => HPS_DRAM_MDQ,
			memory_mem_dqs                   => HPS_DRAM_DQS0_P,
			memory_mem_dqs_n                 => HPS_DRAM_DQS0_N,
			memory_mem_odt                   => HPS_DRAM_MODT,
			memory_mem_dm                    => HPS_DRAM_MDM,
			memory_oct_rzqin                 => HPS_DRAM_RZQ,
			-- HPS Ethernet:
			hps_io_hps_io_emac1_inst_TX_CLK  => HPS_3V3_EMAC0_RGMII_TX_CLK,
			hps_io_hps_io_emac1_inst_TXD0    => HPS_3V3_EMAC0_RGMII_TXD0,
			hps_io_hps_io_emac1_inst_TXD1    => HPS_3V3_EMAC0_RGMII_TXD1,
			hps_io_hps_io_emac1_inst_TXD2    => HPS_3V3_EMAC0_RGMII_TXD2,
			hps_io_hps_io_emac1_inst_TXD3    => HPS_3V3_EMAC0_RGMII_TXD3,
			hps_io_hps_io_emac1_inst_RXD0    => HPS_3V3_EMAC0_RGMII_RXD0,
			hps_io_hps_io_emac1_inst_MDIO    => HPS_3V3_EMAC0_RGMII_MDIO,
			hps_io_hps_io_emac1_inst_MDC     => HPS_3V3_EMAC0_RGMII_MDC,
			hps_io_hps_io_emac1_inst_RX_CTL  => HPS_3V3_EMAC0_RGMII_RX_CTL,
			hps_io_hps_io_emac1_inst_TX_CTL  => HPS_3V3_EMAC0_RGMII_TX_CTL,
			hps_io_hps_io_emac1_inst_RX_CLK  => HPS_3V3_EMAC0_RGMII_RX_CLK,
			hps_io_hps_io_emac1_inst_RXD1    => HPS_3V3_EMAC0_RGMII_RXD1,
			hps_io_hps_io_emac1_inst_RXD2    => HPS_3V3_EMAC0_RGMII_RXD2,
			hps_io_hps_io_emac1_inst_RXD3    => HPS_3V3_EMAC0_RGMII_RXD3,
			-- HPS SD Card
			hps_io_hps_io_sdio_inst_CMD      => HPS_3V3_SDMMC_CMD,
			hps_io_hps_io_sdio_inst_D0       => HPS_3V3_SDMMC_D0,
			hps_io_hps_io_sdio_inst_D1       => HPS_3V3_SDMMC_D1,
			hps_io_hps_io_sdio_inst_CLK      => HPS_3V3_SDMMC_CLK,
			hps_io_hps_io_sdio_inst_D2       => HPS_3V3_SDMMC_D2,
			hps_io_hps_io_sdio_inst_D3       => HPS_3V3_SDMMC_D3,
			-- HPS USB
			hps_io_hps_io_usb1_inst_D0       => HPS_3V3_USB1_D0,
			hps_io_hps_io_usb1_inst_D1       => HPS_3V3_USB1_D1,
			hps_io_hps_io_usb1_inst_D2       => HPS_3V3_USB1_D2,
			hps_io_hps_io_usb1_inst_D3       => HPS_3V3_USB1_D3,
			hps_io_hps_io_usb1_inst_D4       => HPS_3V3_USB1_D4,
			hps_io_hps_io_usb1_inst_D5       => HPS_3V3_USB1_D5,
			hps_io_hps_io_usb1_inst_D6       => HPS_3V3_USB1_D6,
			hps_io_hps_io_usb1_inst_D7       => HPS_3V3_USB1_D7,
			hps_io_hps_io_usb1_inst_CLK      => HPS_3V3_USB1_CLK,
			hps_io_hps_io_usb1_inst_STP      => HPS_3V3_USB1_STP,
			hps_io_hps_io_usb1_inst_DIR      => HPS_3V3_USB1_DIR,
			hps_io_hps_io_usb1_inst_NXT      => HPS_3V3_USB1_NXT,
			-- HPS UART
			hps_io_hps_io_uart0_inst_RX      => HPS_3V3_UART0_RX,
			hps_io_hps_io_uart0_inst_TX      => HPS_3V3_UART0_TX,
			-- HPS I2C
			hps_io_hps_io_i2c0_inst_SDA      => HPS_3V3_I2C0_SCL,
			hps_io_hps_io_i2c0_inst_SCL      => HPS_3V3_I2C0_SDA,
			-- HPS CAN
			hps_io_hps_io_can0_inst_RX 	 => HPS_3V3_CAN0_RX,
			hps_io_hps_io_can0_inst_TX 	 => HPS_3V3_CAN0_TX,
			
			aclr_external_connection_export  => open,
			xy0_external_connection_export 	 => w_Result(31 downto 0),
			xy1_external_connection_export 	 => w_Result(63 downto 32),
			clk_clk 			 => CLOCK0
		);
		
	MULT_ADDER5_Inst : MULT_ADDER5
		port map(
			i_Clk_HPS 			 => CLOCK0,
			i_Clk_FPGA 			 => CLOCK50,
			i_Dataa_0 			 => (others => '0'),
			i_Datab_0 			 => (others => '0'),
			i_Write_EN 			 => '0',
			i_aclr 				 => '0',
		 	
	 		o_Full 				 => open,
			o_Result 			 => w_Result,
			o_Result_x 			 => open,
			o_Result_y 			 => open
		);
	
	
end architecture RTL;
