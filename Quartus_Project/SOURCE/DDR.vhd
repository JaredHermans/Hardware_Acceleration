-------------------------------------------------------------------------------------------------------------------------------
-- Jared Hermans
-------------------------------------------------------------------------------------------------------------------------------
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity DDR is
    Port (
				CLOCK50 						: in    STD_LOGIC; 	-- FPGA CLOCK
				CLOCK0 							: in    STD_LOGIC; 	-- HPS CLOCK
				
				i_Btn0 							: in    STD_LOGIC;
				i_Btn1   						: in    std_logic; 	-- Clock enable button
				
				SW 								: in    std_logic_vector(9 downto 0);
				LEDS 							: out   std_logic_vector(9 downto 0);
				
				i_RX_GPIO_0						: in    std_logic;
				o_TX_GPIO_1 					: out   std_logic;
				
				o_Segment1_A 					: out   std_logic;
				o_Segment1_B					: out   std_logic;
				o_Segment1_C 					: out   std_logic;
				o_Segment1_D 					: out   std_logic;
				o_Segment1_E 					: out   std_logic;
				o_Segment1_F 					: out   std_logic;
				o_Segment1_G	    			: out   std_logic;
				
				o_Segment2_A 					: out   std_logic;
				o_Segment2_B 					: out   std_logic;
				o_Segment2_C 					: out   std_logic;
				o_Segment2_D 					: out   std_logic;
				o_Segment2_E 					: out   std_logic; 
				o_Segment2_F 					: out   std_logic;
				o_Segment2_G	    			: out   std_logic;
				
				o_Segment3_A 					: out   std_logic;
				o_Segment3_B 					: out   std_logic;
				o_Segment3_C 					: out   std_logic; 
				o_Segment3_D 					: out   std_logic;
				o_Segment3_E 					: out   std_logic;
				o_Segment3_F 					: out   std_logic;
				o_Segment3_G 					: out   std_logic;
				
				o_Segment4_A 					: out   std_logic;
				o_Segment4_B 					: out   std_logic;
				o_Segment4_C 					: out   std_logic;
				o_Segment4_D 					: out   std_logic;
				o_Segment4_E 					: out   std_logic;
				o_Segment4_F 					: out   std_logic;
				o_Segment4_G	 				: out   std_logic;
				
				o_Segment5_A  					: out   std_logic;
				o_Segment5_B 					: out   std_logic;
				o_Segment5_C 					: out   std_logic;
				o_Segment5_D 					: out   std_logic;
				o_Segment5_E 					: out   std_logic;
				o_Segment5_F 					: out   std_logic;
				o_Segment5_G 					: out   std_logic;
				
				o_Segment6_A 					: out   std_logic;
				o_Segment6_B 					: out   std_logic;
				o_Segment6_C 					: out   std_logic;
				o_Segment6_D 					: out   std_logic;
				o_Segment6_E 					: out   std_logic;
				o_Segment6_F 					: out   std_logic;
				o_Segment6_G	 				: out   std_logic;
	 	      -- HPS pin declarastion
			   -- =====================
			   --
			   -- DDR3
			    HPS_DDR3_ADDR 					: out   std_logic_vector(14 downto 0);
				HPS_DDR3_BA 					: out   std_logic_vector(2 downto 0);
				HPS_DDR3_CAS_N 					: out   std_logic;
				HPS_DDR3_CKE 					: out   std_logic;
				HPS_DDR3_CK_N 					: out   std_logic;
				HPS_DDR3_CK_P 					: out   std_logic;
				HPS_DDR3_CS_N 					: out   std_logic;
				HPS_DDR3_DM 					: out   std_logic_vector(3 downto 0);
				HPS_DDR3_DQ 					: inout std_logic_vector(31 downto 0);
				HPS_DDR3_DQS_N 					: inout std_logic_vector(3 downto 0);
				HPS_DDR3_DQS_P 					: inout std_logic_vector(3 downto 0);
				HPS_DDR3_ODT 					: out   std_logic;
				HPS_DDR3_RAS_N 					: out   std_logic;
				HPS_DDR3_RESET_N				: out   std_logic;
				HPS_DDR3_RZQ 					: in    std_logic;
				HPS_DDR3_WE_N 					: out   std_logic;
				
			    -- UART0
			    HPS_3V3_UART0_TX    			: out   STD_LOGIC;
			    HPS_3V3_UART0_RX    			: in    STD_LOGIC;
			
			    -- SD
			    HPS_3V3_SDMMC_CLK   			: out   STD_LOGIC;
			    HPS_3V3_SDMMC_CMD   			: inout STD_LOGIC;
			    HPS_3V3_SDMMC_D0    			: inout STD_LOGIC;
			    HPS_3V3_SDMMC_D1    			: inout STD_LOGIC;
			    HPS_3V3_SDMMC_D2    			: inout STD_LOGIC;
			    HPS_3V3_SDMMC_D3    			: inout STD_LOGIC;
				
				-- I2C
			    HPS_3V3_I2C0_SCL    			: inout STD_LOGIC;
			    HPS_3V3_I2C0_SDA    			: inout STD_LOGIC;
				
				-- CAN
				HPS_3V3_CAN0_TX     			: out   STD_LOGIC;
				HPS_3V3_CAN0_RX     			: in    STD_LOGIC;

				-- EMAC1
			    HPS_3V3_EMAC0_RGMII_TXD0 		: out   STD_LOGIC;
			    HPS_3V3_EMAC0_RGMII_TXD1     	: out   STD_LOGIC;
			    HPS_3V3_EMAC0_RGMII_TXD2     	: out   STD_LOGIC;
			    HPS_3V3_EMAC0_RGMII_TXD3     	: out   STD_LOGIC;
			  
			    HPS_3V3_EMAC0_RGMII_TX_CLK   	: out   STD_LOGIC;
			    HPS_3V3_EMAC0_RGMII_TX_CTL   	: out   STD_LOGIC;
			  
			    HPS_3V3_EMAC0_RGMII_RXD0     	: in    STD_LOGIC;
			    HPS_3V3_EMAC0_RGMII_RXD1     	: in    STD_LOGIC;
			    HPS_3V3_EMAC0_RGMII_RXD2     	: in    STD_LOGIC;
			    HPS_3V3_EMAC0_RGMII_RXD3     	: in    STD_LOGIC;
			  
			    HPS_3V3_EMAC0_RGMII_RX_CLK   	: in    STD_LOGIC;
			    HPS_3V3_EMAC0_RGMII_RX_CTL   	: in    STD_LOGIC;
			  
			    HPS_3V3_EMAC0_RGMII_MDC      	: out   STD_LOGIC;
			    HPS_3V3_EMAC0_RGMII_MDIO     	: inout STD_LOGIC;				

				-- USB
			    HPS_3V3_USB1_D0              	: inout STD_LOGIC;
			    HPS_3V3_USB1_D1              	: inout STD_LOGIC;
		        HPS_3V3_USB1_D2              	: inout STD_LOGIC;
	            HPS_3V3_USB1_D3              	: inout STD_LOGIC;
				HPS_3V3_USB1_D4              	: inout STD_LOGIC;
				HPS_3V3_USB1_D5              	: inout STD_LOGIC;
			    HPS_3V3_USB1_D6              	: inout STD_LOGIC;
			    HPS_3V3_USB1_D7              	: inout STD_LOGIC;
			    HPS_3V3_USB1_CLK             	: in    STD_LOGIC;
			    HPS_3V3_USB1_STP             	: out   STD_LOGIC;
				HPS_3V3_USB1_DIR             	: in    STD_LOGIC;
				HPS_3V3_USB1_NXT             	: in    STD_LOGIC
      );				
end entity DDR;


architecture RTL of DDR is

	signal w_Segment1_A 			: std_logic;
	signal w_Segment1_B 			: std_logic;
	signal w_Segment1_C 			: std_logic;
	signal w_Segment1_D 			: std_logic;
	signal w_Segment1_E 			: std_logic;
	signal w_Segment1_F 			: std_logic;
	signal w_Segment1_G 			: std_logic;
	
	signal w_Segment2_A 			: std_logic;
	signal w_Segment2_B 			: std_logic;
	signal w_Segment2_C 			: std_logic;
	signal w_Segment2_D 			: std_logic;
	signal w_Segment2_E 			: std_logic;
	signal w_Segment2_F 			: std_logic;
	signal w_Segment2_G 			: std_logic;
	
	signal w_Segment3_A 			: std_logic;
	signal w_Segment3_B 			: std_logic;
	signal w_Segment3_C 			: std_logic;
	signal w_Segment3_D 			: std_logic;
	signal w_Segment3_E 			: std_logic;
	signal w_Segment3_F 			: std_logic;
	signal w_Segment3_G 			: std_logic;
	
	signal w_Segment4_A 			: std_logic;
	signal w_Segment4_B 			: std_logic;
	signal w_Segment4_C 			: std_logic;
	signal w_Segment4_D 			: std_logic;
	signal w_Segment4_E 			: std_logic;
	signal w_Segment4_F 			: std_logic;
	signal w_Segment4_G 			: std_logic;
	
	signal w_Segment5_A 			: std_logic;
	signal w_Segment5_B 			: std_logic;
	signal w_Segment5_C 			: std_logic;
	signal w_Segment5_D 			: std_logic;
	signal w_Segment5_E 			: std_logic;
	signal w_Segment5_F 			: std_logic;
	signal w_Segment5_G 			: std_logic;
	
	signal w_Segment6_A 			: std_logic;
	signal w_Segment6_B 			: std_logic;
	signal w_Segment6_C 			: std_logic;
	signal w_Segment6_D 			: std_logic;
	signal w_Segment6_E 			: std_logic;
	signal w_Segment6_F 			: std_logic;
	signal w_Segment6_G 			: std_logic;

	signal FIFO_Data 				: std_logic_vector(127 downto 0);
	signal FIFO_Data_Out 			: std_logic_vector(31 downto 0);
	signal FIFO_Empty 				: std_logic;
	signal FIFO_Read_EN 			: std_logic;
	
	signal w_aclr 					: std_logic;
	signal w_not_aclr 				: std_logic;
	
	signal w_FPGA_Done 				: std_logic;
	signal w_DDR_Done 				: std_logic;
	signal w_HPS_Done 				: std_logic;
	
	signal w_Result 				: std_logic_vector(63 downto 0);
	signal w_Result_x 				: std_logic_vector(63 downto 0);
	signal w_Result_y 				: std_logic_vector(63 downto 0);
	
	signal DDR_Transfer_Done 		: std_logic;
	signal DDR_Full_Done_Time 		: std_logic_vector(25 downto 0);
	signal FPGA_Done_Time 			: std_logic_vector(25 downto 0);
	signal HPS_Done_Time 			: std_logic_vector(25 downto 0);
	
	signal o_Control				: std_logic_vector(31 downto 0);
	signal w_IN_Control 			: std_logic_vector(31 downto 0);
	signal Warning 					: std_logic; -- Goes high when MSB in Result is high (overflow warning)
	
	component Timer is
		port(
			i_Clk 					: in  std_logic;
			i_aclr 					: in  std_logic;
			i_done 					: in  std_logic;
			
			o_Time 					: out std_logic_vector(25 downto 0)
		);
	end component Timer;

	component MULT_ADDER_TOP is
		port(
			i_Clk 					: in  std_logic;
			i_aclr 					: in  std_logic;
			i_Data 					: in  std_logic_vector(127 downto 0);
			i_FIFO_Empty			: in  std_logic;
			i_DDR_Transfer_Done 	: in  std_logic;
			
			o_FIFO_Read_EN 			: out std_logic;
			o_Done 					: out std_logic;
			o_Result 				: out std_logic_vector(63 downto 0);
			o_Result_x 				: out std_logic_vector(63 downto 0);
			o_Result_y 				: out std_logic_vector(63 downto 0)
		);
	end component MULT_ADDER_TOP;
	
    component QSYS is
        port (
            export_aclr                     : in    std_logic                      := 'X';             -- aclr
            export_fifo_read_en             : in    std_logic                      := 'X';             -- fifo_read_en
            export_fifo_data                : out   std_logic_vector(127 downto 0);                    -- fifo_data
            export_fifo_empty               : out   std_logic;                                         -- fifo_empty
            export_ddr_transfer_done        : out   std_logic;                                         -- ddr_transfer_done
            export_clk                      : in    std_logic                      := 'X';             -- clk
            hps_io_hps_io_emac1_inst_TX_CLK : out   std_logic;                                         -- hps_io_emac1_inst_TX_CLK
            hps_io_hps_io_emac1_inst_TXD0   : out   std_logic;                                         -- hps_io_emac1_inst_TXD0
            hps_io_hps_io_emac1_inst_TXD1   : out   std_logic;                                         -- hps_io_emac1_inst_TXD1
            hps_io_hps_io_emac1_inst_TXD2   : out   std_logic;                                         -- hps_io_emac1_inst_TXD2
            hps_io_hps_io_emac1_inst_TXD3   : out   std_logic;                                         -- hps_io_emac1_inst_TXD3
            hps_io_hps_io_emac1_inst_RXD0   : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RXD0
            hps_io_hps_io_emac1_inst_MDIO   : inout std_logic                      := 'X';             -- hps_io_emac1_inst_MDIO
            hps_io_hps_io_emac1_inst_MDC    : out   std_logic;                                         -- hps_io_emac1_inst_MDC
            hps_io_hps_io_emac1_inst_RX_CTL : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RX_CTL
            hps_io_hps_io_emac1_inst_TX_CTL : out   std_logic;                                         -- hps_io_emac1_inst_TX_CTL
            hps_io_hps_io_emac1_inst_RX_CLK : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RX_CLK
            hps_io_hps_io_emac1_inst_RXD1   : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RXD1
            hps_io_hps_io_emac1_inst_RXD2   : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RXD2
            hps_io_hps_io_emac1_inst_RXD3   : in    std_logic                      := 'X';             -- hps_io_emac1_inst_RXD3
            hps_io_hps_io_sdio_inst_CMD     : inout std_logic                      := 'X';             -- hps_io_sdio_inst_CMD
            hps_io_hps_io_sdio_inst_D0      : inout std_logic                      := 'X';             -- hps_io_sdio_inst_D0
            hps_io_hps_io_sdio_inst_D1      : inout std_logic                      := 'X';             -- hps_io_sdio_inst_D1
            hps_io_hps_io_sdio_inst_CLK     : out   std_logic;                                         -- hps_io_sdio_inst_CLK
            hps_io_hps_io_sdio_inst_D2      : inout std_logic                      := 'X';             -- hps_io_sdio_inst_D2
            hps_io_hps_io_sdio_inst_D3      : inout std_logic                      := 'X';             -- hps_io_sdio_inst_D3
            hps_io_hps_io_usb1_inst_D0      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D0
            hps_io_hps_io_usb1_inst_D1      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D1
            hps_io_hps_io_usb1_inst_D2      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D2
            hps_io_hps_io_usb1_inst_D3      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D3
            hps_io_hps_io_usb1_inst_D4      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D4
            hps_io_hps_io_usb1_inst_D5      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D5
            hps_io_hps_io_usb1_inst_D6      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D6
            hps_io_hps_io_usb1_inst_D7      : inout std_logic                      := 'X';             -- hps_io_usb1_inst_D7
            hps_io_hps_io_usb1_inst_CLK     : in    std_logic                      := 'X';             -- hps_io_usb1_inst_CLK
            hps_io_hps_io_usb1_inst_STP     : out   std_logic;                                         -- hps_io_usb1_inst_STP
            hps_io_hps_io_usb1_inst_DIR     : in    std_logic                      := 'X';             -- hps_io_usb1_inst_DIR
            hps_io_hps_io_usb1_inst_NXT     : in    std_logic                      := 'X';             -- hps_io_usb1_inst_NXT
            hps_io_hps_io_uart0_inst_RX     : in    std_logic                      := 'X';             -- hps_io_uart0_inst_RX
            hps_io_hps_io_uart0_inst_TX     : out   std_logic;                                         -- hps_io_uart0_inst_TX
            hps_io_hps_io_i2c0_inst_SDA     : inout std_logic                      := 'X';             -- hps_io_i2c0_inst_SDA
            hps_io_hps_io_i2c0_inst_SCL     : inout std_logic                      := 'X';             -- hps_io_i2c0_inst_SCL
            hps_io_hps_io_can0_inst_RX      : in    std_logic                      := 'X';             -- hps_io_can0_inst_RX
            hps_io_hps_io_can0_inst_TX      : out   std_logic;                                         -- hps_io_can0_inst_TX
            i_control_export                : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- export
            memory_mem_a                    : out   std_logic_vector(14 downto 0);                     -- mem_a
            memory_mem_ba                   : out   std_logic_vector(2 downto 0);                      -- mem_ba
            memory_mem_ck                   : out   std_logic;                                         -- mem_ck
            memory_mem_ck_n                 : out   std_logic;                                         -- mem_ck_n
            memory_mem_cke                  : out   std_logic;                                         -- mem_cke
            memory_mem_cs_n                 : out   std_logic;                                         -- mem_cs_n
            memory_mem_ras_n                : out   std_logic;                                         -- mem_ras_n
            memory_mem_cas_n                : out   std_logic;                                         -- mem_cas_n
            memory_mem_we_n                 : out   std_logic;                                         -- mem_we_n
            memory_mem_reset_n              : out   std_logic;                                         -- mem_reset_n
            memory_mem_dq                   : inout std_logic_vector(31 downto 0)  := (others => 'X'); -- mem_dq
            memory_mem_dqs                  : inout std_logic_vector(3 downto 0)   := (others => 'X'); -- mem_dqs
            memory_mem_dqs_n                : inout std_logic_vector(3 downto 0)   := (others => 'X'); -- mem_dqs_n
            memory_mem_odt                  : out   std_logic;                                         -- mem_odt
            memory_mem_dm                   : out   std_logic_vector(3 downto 0);                      -- mem_dm
            memory_oct_rzqin                : in    std_logic                      := 'X';             -- oct_rzqin
            o_control_export                : out   std_logic_vector(31 downto 0);                     -- export
            ddr_time_export                 : in    std_logic_vector(25 downto 0)  := (others => 'X'); -- export
            fpga_time_export                : in    std_logic_vector(25 downto 0)  := (others => 'X'); -- export
            hps_time_export                 : in    std_logic_vector(25 downto 0)  := (others => 'X'); -- export
            bluetooth_RXD                   : in    std_logic                      := 'X';             -- RXD
            bluetooth_TXD                   : out   std_logic;                                         -- TXD
            xy_dataa_export                 : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- export
            xy_datab_export                 : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- export
            xx_dataa_export                 : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- export
            xx_datab_export                 : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- export
            yy_dataa_export                 : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- export
            yy_datab_export                 : in    std_logic_vector(31 downto 0)  := (others => 'X')  -- export
        );
    end component QSYS;

	
begin

	Timer_Inst0 : Timer
		port map(
			i_Clk 							=> CLOCK50,
			i_aclr 							=> w_not_aclr,
			i_done 							=> DDR_Transfer_Done,
			
			o_Time 							=> DDR_Full_Done_Time
		);
		
	Timer_Inst1 : Timer
		port map(
			i_Clk 							=> CLOCK50,
			i_aclr 							=> w_not_aclr,
			i_done 							=> w_FPGA_Done,
			
			o_Time 							=> FPGA_Done_Time
		);
		
	Timer_Inst2 : Timer
		port map(
			i_Clk 							=> CLOCK50,
			i_aclr 							=> w_not_aclr,
			i_done 							=> w_HPS_Done,
			
			o_Time 							=> HPS_Done_Time
		);
	
	MULT_ADDER_TOP_Inst : MULT_ADDER_TOP
		port map(
			i_Clk 							=> CLOCK50,
			i_aclr 							=> w_not_aclr,
			i_Data 							=> FIFO_Data,
			i_FIFO_Empty 					=> FIFO_Empty,
			i_DDR_Transfer_Done 			=> DDR_Transfer_Done,
			
			o_FIFO_Read_EN 					=> FIFO_Read_EN,
			o_Done 							=> w_FPGA_Done,
			o_Result 						=> w_Result,
			o_Result_x 						=> w_result_x,
			o_Result_y 						=> w_Result_y
		);

	QSYS_Inst : QSYS
        port map (
		
			-- Custom IP 1 Export
			export_aclr                 	 => w_not_aclr,
		    export_fifo_read_en              => FIFO_Read_EN,
            export_fifo_data                 => FIFO_Data,
		    export_fifo_empty 				 => FIFO_Empty,
			export_ddr_transfer_done 		 => DDR_Transfer_Done,
			export_Clk 						 => CLOCK50,
			
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
			hps_io_hps_io_can0_inst_RX 		 => HPS_3V3_CAN0_RX,
			hps_io_hps_io_can0_inst_TX 		 => HPS_3V3_CAN0_TX,
			
			-- PIO control Port (FPGA => HPS)
			i_control_export 				 => w_IN_Control,
			
			-- HPS DDR3
			memory_mem_a                     => HPS_DDR3_ADDR,
			memory_mem_ba                    => HPS_DDR3_BA,
			memory_mem_ck                    => HPS_DDR3_CK_P,
			memory_mem_ck_n                  => HPS_DDR3_CK_N,
			memory_mem_cke                   => HPS_DDR3_CKE,
			memory_mem_cs_n                  => HPS_DDR3_CS_N,
			memory_mem_ras_n                 => HPS_DDR3_RAS_N,
			memory_mem_cas_n                 => HPS_DDR3_CAS_N,
			memory_mem_we_n                  => HPS_DDR3_WE_N,
			memory_mem_reset_n               => HPS_DDR3_RESET_N,
			memory_mem_dq                    => HPS_DDR3_DQ,
			memory_mem_dqs                   => HPS_DDR3_DQS_P,
			memory_mem_dqs_n                 => HPS_DDR3_DQS_N,
			memory_mem_odt                   => HPS_DDR3_ODT,
			memory_mem_dm                    => HPS_DDR3_DM,
			memory_oct_rzqin                 => HPS_DDR3_RZQ,
			
			-- PIO control port (HPS => FPGA)
			o_control_export 				 => o_Control,
			
			-- PIO ports for FPGA timers
			ddr_time_export 				 => DDR_Full_Done_Time,			
			fpga_time_export 				 => FPGA_Done_Time,
			hps_time_export 				 => HPS_Done_Time,
			
			-- Uart IP for bluetooth
			bluetooth_RXD 					 => i_RX_GPIO_0,
			bluetooth_TXD 					 => o_TX_GPIO_1,
			
			-- PIO ports for calculated values
			xy_dataa_export 				 => w_Result(31 downto 0),
			xy_datab_export 				 => w_Result(63 downto 32),
			xx_dataa_export 				 => w_Result_x(31 downto 0),
			xx_datab_export 				 => w_Result_x(63 downto 32),
			yy_dataa_export 				 => w_Result_y(31 downto 0),
			yy_datab_export 				 => w_Result_y(63 downto 32)
         );
		 
	w_not_aclr 	 			<= not o_Control(0);						-- Active low aclr
	w_HPS_Done 				<= o_Control(1);
	Warning 				<= '1' when (w_Result_x(63) = '1' or w_Result_y(63) = '1') else '0'; -- Overflow warning
	w_In_Control 			<= X"0000000" & "00" & Warning & w_FPGA_Done;
		 				
	SevenSeg1_Inst1 : entity work.Binary_To_7Segment
		port map(
			i_Clk 			=> CLOCK50,
			i_Binary_Num 	=> FIFO_Data_Out(3 downto 0),
			o_Segment_A 	=> w_Segment1_A,
			o_Segment_B 	=> w_Segment1_B,
			o_Segment_C 	=> w_Segment1_C,
			o_Segment_D 	=> w_Segment1_D,
			o_Segment_E 	=> w_Segment1_E,
			o_Segment_F 	=> w_Segment1_F,
			o_Segment_G 	=> w_Segment1_G
		);
		
	o_Segment1_A <= not w_Segment1_A;
	o_Segment1_B <= not w_Segment1_B;
	o_Segment1_C <= not w_Segment1_C;
	o_Segment1_D <= not w_Segment1_D;
	o_Segment1_E <= not w_Segment1_E;
	o_Segment1_F <= not w_Segment1_F;
	o_Segment1_G <= not w_Segment1_G;
	
	SevenSeg1_Inst2 : entity work.Binary_To_7Segment
		port map(
			i_Clk 			=> CLOCK50,
			i_Binary_num 	=> FIFO_Data_Out(7 downto 4),
			o_Segment_A 	=> w_Segment2_A,
			o_Segment_B 	=> w_Segment2_B,
			o_Segment_C 	=> w_Segment2_C,
			o_Segment_D 	=> w_Segment2_D,
			o_Segment_E		=> w_Segment2_E,
			o_Segment_F 	=> w_Segment2_F,
			o_Segment_G 	=> w_Segment2_G
		);
		
	o_Segment2_A <= not w_Segment2_A;
	o_Segment2_B <= not w_Segment2_B;
	o_Segment2_C <= not w_Segment2_C;
	o_Segment2_D <= not w_Segment2_D;
	o_Segment2_E <= not w_Segment2_E;
	o_Segment2_F <= not w_Segment2_F;
	o_Segment2_G <= not w_Segment2_G;
	
	SevenSeg1_Inst3 : entity work.Binary_To_7Segment
		port map(
			i_Clk			=> CLOCK50,
			i_Binary_Num 	=> FIFO_Data_Out(11 downto 8),
			o_Segment_A 	=> w_Segment3_A,
			o_Segment_B 	=> w_Segment3_B,
			o_Segment_C 	=> w_Segment3_C,
			o_Segment_D 	=> w_Segment3_D,
			o_Segment_E 	=> w_Segment3_E,
			o_Segment_F 	=> w_Segment3_F,
			o_Segment_G 	=> w_Segment3_G
		);
		
	o_Segment3_A <= not w_Segment3_A;
	o_Segment3_B <= not w_Segment3_B;
	o_Segment3_C <= not w_Segment3_C;
	o_Segment3_D <= not w_Segment3_D;
	o_Segment3_E <= not w_Segment3_E;
	o_Segment3_F <= not w_Segment3_F;
	o_Segment3_G <= not w_Segment3_G;
	
	SevenSeg1_Inst4 : entity work.Binary_To_7Segment
		port map(
			i_Clk 			=> CLOCK50,
			i_Binary_Num 	=> FIFO_Data_Out(15 downto 12),
			o_Segment_A 	=> w_Segment4_A,
			o_Segment_B 	=> w_Segment4_B,
			o_Segment_C 	=> w_Segment4_C,
			o_Segment_D 	=> w_Segment4_D,
			o_Segment_E 	=> w_Segment4_E,
			o_Segment_F 	=> w_Segment4_F,
			o_Segment_G 	=> w_Segment4_G
		);
		
	o_Segment4_A <= not w_Segment4_A;
	o_Segment4_B <= not w_Segment4_B;
	o_Segment4_C <= not w_Segment4_C;
	o_Segment4_D <= not w_Segment4_D;
	o_Segment4_E <= not w_Segment4_E;
	o_Segment4_F <= not w_Segment4_F;
	o_Segment4_G <= not w_Segment4_G;
			
	
	SevenSeg1_Inst5 : entity work.Binary_To_7Segment
		port map(
			i_Clk 			=> CLOCK50,
			i_Binary_Num	=> FIFO_Data_Out(19 downto 16),
			o_Segment_A 	=> w_Segment5_A,
			o_Segment_B 	=> w_Segment5_B,
			o_Segment_C 	=> w_Segment5_C,
			o_Segment_D 	=> w_Segment5_D,
			o_Segment_E 	=> w_Segment5_E,
			o_Segment_F 	=> w_Segment5_F,
			o_Segment_G 	=> w_Segment5_G
		);
		
	o_Segment5_A <= not w_Segment5_A;
	o_Segment5_B <= not w_Segment5_B;
	o_Segment5_C <= not w_Segment5_C;
	o_Segment5_D <= not w_Segment5_D;
	o_Segment5_E <= not w_Segment5_E;
	o_Segment5_F <= not w_Segment5_F;
	o_Segment5_G <= not w_Segment5_G;
	
	SevenSeg1_Inst6 : entity work.Binary_To_7Segment
		port map(
			i_clk 			=> CLOCK50,
			i_Binary_Num 	=> FIFO_Data_Out(23 downto 20),
			o_Segment_A 	=> w_Segment6_A,
			o_Segment_B 	=> w_Segment6_B,
			o_Segment_C 	=> w_Segment6_C,
			o_Segment_D 	=> w_Segment6_D,
			o_Segment_E 	=> w_Segment6_E,
			o_Segment_F 	=> w_Segment6_F,
			o_Segment_G 	=> w_Segment6_G
		);
		
	o_Segment6_A <= not w_Segment6_A;
	o_Segment6_B <= not w_Segment6_B;
	o_Segment6_C <= not w_Segment6_C;
	o_Segment6_D <= not w_Segment6_D;
	o_Segment6_E <= not w_Segment6_E;
	o_Segment6_F <= not w_Segment6_F;
	o_Segment6_G <= not w_Segment6_G;
	
	with SW(4 downto 0) select
		FIFO_Data_Out <= 	FIFO_Data(31 downto 0) 					when "00000",
							FIFO_Data(63 downto 32) 				when "00001",
							FIFO_Data(95 downto 64) 				when "00010",
							FIFO_Data(127 downto 96) 				when "00011",
							X"000000" & FIFO_Data(127 downto 120) 	when "00100",
							X"0000000" & "000" & DDR_Transfer_Done 	when "00101",
							w_Result(31 downto 0) 					when "01011",
							w_Result(55 downto 24) 					when "01100",
							w_Result_x(31 downto 0) 				when "01101",
							w_Result_x(55 downto 24) 				when "01110",
							w_Result_y(31 downto 0) 				when "01111",
							w_Result_y(55 downto 24) 				when "10000",
							(others => '0') 						when others;
							
end architecture RTL;
