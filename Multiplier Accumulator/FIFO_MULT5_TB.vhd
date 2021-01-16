library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity FIFO_MULT5_TB is
end entity FIFO_MULT5_TB;

architecture BEHAVE of FIFO_MULT5_TB is

	constant c_Clk_HPS 	: time := 10 ns;
	constant c_Clk_FPGA 	: time := 20 ns;

	signal r_Dataa_0 		: std_logic_vector(63 downto 0) := (others => '0');
	signal r_Datab_0 		: std_logic_vector(63 downto 0) := (others => '0');
	signal r_Write_EN 	: std_logic := '0';
	signal r_Clk_HPS 		: std_logic := '1';
	signal r_Clk_FPGA 	: std_logic := '1';
	signal r_aclr 			: std_logic := '0';
	signal w_Full 			: std_logic;
	signal w_Result 		: std_logic_vector(47 downto 0);
	signal w_Result_x 	: std_logic_vector(47 downto 0);
	signal w_Result_y 	: std_logic_vector(47 downto 0);
	
	file file_VECTORS : text;
	file file_RESULTS : text;
	
	component FIFO_MULT5 is
		port(
			i_Clk_HPS 		: in  std_logic;
			i_Clk_FPGA 		: in  std_logic;
			
			i_Dataa_0 		: in  std_logic_vector(63 downto 0);
			i_Datab_0 		: in  std_logic_vector(63 downto 0);
		
			i_Write_EN 		: in  std_logic;
			i_aclr 			: in  std_logic;
			
			o_Full	 		: out std_logic;
			o_Result 		: out std_logic_vector(47 downto 0);
			o_Result_x 		: out std_logic_vector(47 downto 0);
			o_Result_y 		: out std_logic_vector(47 downto 0)
		);
	end component FIFO_MULT5;
	
begin

	FIFO_MULT5_Inst : FIFO_MULT5
		port map(
			i_Clk_HPS 		=> r_Clk_HPS,
			i_Clk_FPGA 		=> r_Clk_FPGA,
			i_Dataa_0 		=> r_Dataa_0,
			i_Datab_0 		=> r_Datab_0,
		
			i_Write_EN 		=> r_Write_EN,
			i_aclr 			=> r_aclr,
			
			o_Full 			=> w_Full,
			o_Result 		=> w_Result,
			o_Result_x 		=> w_Result_x,
			o_Result_y 		=> w_Result_y
		);
		
	r_Clk_HPS <= not r_Clk_HPS after c_Clk_HPS / 2;
	r_Clk_FPGA <= not r_Clk_FPGA after c_Clk_FPGA / 2;
	
	process is 
	
		variable v_OutLine 	: line;
			variable v_InLine 	: line;
			variable v_Dataa_0 	: std_logic_vector(63 downto 0);
			variable v_Datab_0 	: std_logic_vector(63 downto 0);
			variable v_Space 		: character;
			
			variable v_Count 		: integer range 0 to 200 := 0;
			variable v_I 			: integer range 0 to 200 := 0;
	
	begin
	
		file_open(file_VECTORS, "input_vectors.txt", read_mode);
		file_open(file_RESULTS, "output_results.txt",write_mode);

		r_Write_EN <= '1';
		
		while not endfile(file_VECTORS) loop 
			readline(file_VECTORS , v_InLine);
			hread(v_InLine, v_Dataa_0);
			read(v_InLine, v_Space);		-- Read in the space character
			hread(v_InLine, v_Datab_0);
			
			-- Pass the variable to a signal
			r_dataa_0 <= v_Dataa_0;
			r_datab_0 <= v_Datab_0;
			
			wait for 10 ns; 					-- One Clock Cycle
			v_I := v_I + 1;
			v_Count := v_Count + 1;
			
			if v_I = 2 then
				hwrite(v_OutLine, w_result);
				writeline(file_RESULTS, v_OutLine);
				v_I := 0;
			end if;
			
		end loop;
		
		r_Write_EN <= '0';
		if v_I = 1 then
			wait for 10 ns;
		end if;
		
		v_I := 0;
		
		while v_I < v_Count loop
			hwrite(v_OutLine, w_result);
			writeline(file_RESULTS, v_OutLine);
			v_I := v_I + 1;
			wait for 20 ns;
		end loop;
		
		file_close(file_VECTORS);
		file_close(file_RESULTS);
		
		wait for 500 ns;
		r_aclr 		<= '1';
		wait for 20 ns;
		
		assert false report "Test Complete" severity failure;
		
	end process;
end architecture BEHAVE;