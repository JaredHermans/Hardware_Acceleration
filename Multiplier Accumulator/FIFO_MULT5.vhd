library ieee;
use ieee.std_logic_1164.all;

entity FIFO_MULT5 is
	port(
		i_Clk_HPS 			: in  std_logic;
		i_Clk_FPGA 			: in  std_logic;
		
		i_Dataa_0 			: in  std_logic_vector(63 downto 0);
		i_Datab_0 			: in  std_logic_vector(63 downto 0);
		
		i_Write_EN 			: in  std_logic;
		i_aclr 				: in  std_logic;
		
		o_Full 				: out std_logic;
		o_Result 			: out std_logic_vector(47 downto 0);
		o_Result_x 			: out std_logic_vector(47 downto 0);
		o_Result_y 			: out std_logic_vector(47 downto 0)
	);
end entity FIFO_MULT5;

architecture RTL of FIFO_MULT5 is

	signal w_Read_EN 		: std_logic;
	signal w_Empty 		: std_logic;
	signal w_ena0 			: std_logic;
	
	signal w_Dataa 		: std_logic_vector(63 downto 0);
	signal w_Datab 		: std_logic_vector(63 downto 0);
	
	component FIFO_IP is
		port(
			aclr 		: in  std_logic := '0';
			data 		: in  std_logic_vector(63 downto 0);
			rdclk 	: in  std_logic;
			rdreq 	: in  std_logic;
			wrclk 	: in  std_logic;
			wrreq 	: in  std_logic;
			q 			: out std_logic_vector(63 downto 0);
			rdempty 	: out std_logic;
			wrfull 	: out std_logic
		);
	end component FIFO_IP;
	
	component MULT_ADDER is
		port(
			result 	: out std_logic_vector(47 downto 0);
			dataa_0 	: in  std_logic_vector(15 downto 0);
			dataa_1 	: in  std_logic_vector(15 downto 0);
			dataa_2 	: in  std_logic_vector(15 downto 0);
			dataa_3 	: in  std_logic_vector(15 downto 0);
			datab_0  : in  std_logic_vector(15 downto 0);
			datab_1 	: in  std_logic_vector(15 downto 0);
			datab_2 	: in  std_logic_vector(15 downto 0);
			datab_3 	: in  std_logic_vector(15 downto 0);
			
			clock0 	: in  std_logic;
			ena0 		: in  std_logic;
			aclr0 	: in  std_logic
		);
	end component MULT_ADDER;
	
	component CONTROL is
		port(
			i_Clk 	: in  std_logic;
			i_Empty 	: in  std_logic;
			o_ena0 	: out std_logic;
			o_Read_EN: out std_logic
		);
	end component CONTROL;
	
begin

	FIFO_IP_Inst_1 : FIFO_IP
		port map(
			aclr 		=> i_aclr,
			data 		=> i_Dataa_0,
			rdclk 	=> i_Clk_FPGA,
			rdreq 	=> w_Read_EN,
			wrclk 	=> i_Clk_HPS,
			wrreq 	=> i_Write_EN,
			q 			=> w_Dataa,
			rdempty 	=> w_Empty,
			wrfull 	=> o_Full
		);
		
	FIFO_IP_Inst_2 : FIFO_IP
		port map(
			aclr 		=> i_aclr,
			data 		=> i_Datab_0,
			rdclk 	=> i_Clk_FPGA,
			rdreq 	=> w_Read_EN,
			wrclk		=> i_Clk_HPS,
			wrreq 	=> i_Write_EN,
			q 			=> w_Datab,
			rdempty 	=> open,
			wrfull 	=> open
		);
		
	CONTROL_Inst : CONTROL
		port map(
			i_Clk 	=> i_Clk_FPGA,
			i_Empty  => w_Empty,
			o_ena0 	=> w_ena0,
			o_Read_EN=> w_Read_EN
		);
		
	MULT_ADDER_Inst_1 : MULT_ADDER
		port map(
			result 	=> o_Result,
			dataa_0  => w_Dataa(15 downto 0),
			dataa_1  => w_Dataa(31 downto 16),
			dataa_2  => w_Dataa(47 downto 32),
			dataa_3  => w_Dataa(63 downto 48),
			datab_0 	=> w_Datab(15 downto 0),
			datab_1  => w_Datab(31 downto 16),
			datab_2  => w_Datab(47 downto 32),
			datab_3  => w_Datab(63 downto 48),
			clock0 	=> i_Clk_FPGA,
			ena0 		=> w_ena0,
			aclr0 	=> i_aclr
		);
		
	MULT_ADDER_Inst_2 : MULT_ADDER
		port map(
			result 	=> o_Result_x,
			dataa_0  => w_Dataa(15 downto 0),
			dataa_1  => w_Dataa(31 downto 16),
			dataa_2  => w_Dataa(47 downto 32),
			dataa_3  => w_Dataa(63 downto 48),
			datab_0 	=> w_Dataa(15 downto 0),
			datab_1  => w_Dataa(31 downto 16),
			datab_2  => w_Dataa(47 downto 32),
			datab_3  => w_Dataa(63 downto 48),
			clock0 	=> i_Clk_FPGA,
			ena0 		=> w_ena0,
			aclr0 	=> i_aclr
		);
		
	MULT_ADDER_Inst_3 : MULT_ADDER
		port map(
			result 	=> o_Result_y,
			dataa_0  => w_Datab(15 downto 0),
			dataa_1  => w_Datab(31 downto 16),
			dataa_2  => w_Datab(47 downto 32),
			dataa_3  => w_Datab(63 downto 48),
			datab_0 	=> w_Datab(15 downto 0),
			datab_1  => w_Datab(31 downto 16),
			datab_2  => w_Datab(47 downto 32),
			datab_3  => w_Datab(63 downto 48),
			clock0 	=> i_Clk_FPGA,
			ena0 		=> w_ena0,
			aclr0 	=> i_aclr
		);
		
end architecture RTL;