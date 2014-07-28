library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.config.all;

entity tb_periph_timestamp is
end entity;

architecture tb of tb_periph_timestamp is

	component periph_timestamp
		generic (
			-- Decoder bit width (defines how many bits are considered for address decoding)
			DEC_WD : natural := 2;
			-- Register base address (must be aligned to decoder bit width)
			BASE_ADDR :natural := 16#198#
		);
		port (
			per_dout :  out std_logic_vector(15 downto 0);
			mclk :  in std_logic;
			per_addr :  in std_logic_vector( PER_MSB downto 0 );
			per_din :  in std_logic_vector(15 downto 0);
			per_en :  in std_logic;
			per_we :  in std_logic_vector( 1 downto 0 );
			puc_rst :  in std_logic;
			
			tscount : out std_logic_vector (15 downto 0)
		);
	end component;
	
signal per_dout : std_logic_vector(15 downto 0);
signal mclk : std_logic := '0';
signal addr : std_logic_vector( 15 downto 0 );
alias per_addr : std_logic_vector( PER_MSB downto 0 ) is addr(PER_MSB+1 downto 1);
signal per_din : std_logic_vector(15 downto 0) := (others => '0');
signal per_en :  std_logic := '0';
signal per_we : std_logic_vector( 1 downto 0 ) := "00";
signal puc_rst : std_logic := '0';

-- constant clk_period : time := (10**9/DCO_FREQ)*1ns;
constant clk_period : time := 20 ns;

signal sim_finished : std_logic := '0';
signal sim_info : string(1 to 64);

function string_pad(instring: string; strlen: natural) return string is
begin
	return instring & (instring'length to strlen-1 => ' ');	-- character'val(0) as string terminator doesn't look nice
end function;

begin
	uut: periph_timestamp
		generic map (DEC_WD => 2, BASE_ADDR => 16#198#)
		port map (
			per_dout => per_dout,
			mclk => mclk,
			per_addr	=> per_addr,
			per_din => per_din,
			per_en => per_en,
			per_we => per_we,
			puc_rst => puc_rst
		);

	clk_process: process
	begin
		mclk <= '1';
		wait for clk_period/2;
		mclk <= '0';
		wait for clk_period/2;

		if (sim_finished = '1') then
			wait;
		end if;
	end process;
	
	stim_process: process
	begin
		sim_info <= string_pad("reset", sim_info'length);
		puc_rst <= '1';
		addr <= X"0000";
		wait for clk_period*2;
		
		sim_info <= string_pad("write to register_tsdiv", sim_info'length);
		puc_rst <= '0';
		per_en <= '1';
		addr <= X"019A";
		per_we <= "10";
		per_din <= x"0000";
		wait for clk_period;
		
		sim_info <= string_pad("read register_tscount", sim_info'length);
		puc_rst <= '0';
		per_en <= '1';
		addr <= X"0198";
		per_we <= "00";
		per_din <= x"0000";
		wait for clk_period;

		sim_info <= string_pad("read register_tsdiv", sim_info'length);
		puc_rst <= '0';
		per_en <= '1';
		addr <= X"019A";
		per_we <= "00";
		per_din <= x"0000";
		wait for clk_period;
		
		sim_info <= string_pad("see tscount counting", sim_info'length);
		per_we <= "00";
		wait for clk_period*10;
		
		sim_info <= string_pad("read register_tscount", sim_info'length);
		puc_rst <= '0';
		per_en <= '1';
		addr <= X"0198";
		per_we <= "00";
		per_din <= x"0000";
		wait for clk_period;
		
		sim_info <= string_pad("write to register_tsdiv", sim_info'length);
		puc_rst <= '0';
		per_en <= '1';
		addr <= X"019A";
		per_we <= "11";
		per_din <= x"0004";
		wait for clk_period;
		
		sim_info <= string_pad("see tscount counting", sim_info'length);
		per_we <= "00";
		addr <= X"0198";
		wait for clk_period*5;
		
		sim_info <= string_pad("disable peripheral", sim_info'length);
		per_en <= '0';
		wait for clk_period;
		
		sim_info <= string_pad("enable peripheral", sim_info'length);
		per_en <= '1';
		wait for clk_period;
		
		sim_info <= string_pad("reset", sim_info'length);
		puc_rst <= '1';
		sim_finished <= '1';
		wait;
	end process;
	
end architecture;