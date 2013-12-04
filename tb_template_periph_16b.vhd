library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

use work.config.all;

entity tb_template_periph_16b is
end entity;

architecture tb of tb_template_periph_16b is

	COMPONENT template_periph_16b
		GENERIC ( DEC_WD : INTEGER := 3; BASE_ADDR : INTEGER := 400 );
		PORT
		(
			per_dout		:	 OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			mclk		:	 IN STD_LOGIC;
			per_addr		:	 IN STD_LOGIC_VECTOR(PER_MSB DOWNTO 0);
			per_din		:	 IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			per_en		:	 IN STD_LOGIC;
			per_we		:	 IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			puc_rst		:	 IN STD_LOGIC
		);
	END COMPONENT;
	
signal per_dout : std_logic_vector(15 downto 0);
signal mclk : std_logic := '0';
signal per_addr : std_logic_vector( PER_MSB downto 0 );
signal per_din : std_logic_vector(15 downto 0) := (others => '0');
signal per_en :  std_logic := '0';
signal per_we : std_logic_vector( 1 downto 0 ) := "00";
signal puc_rst : std_logic := '0';

-- constant clk_period : time := (10**9/DCO_FREQ)*1ns;
constant clk_period : time := 20 ns;

begin
	uut: template_periph_16b
		generic map (DEC_WD => 3, BASE_ADDR => 400)
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
		mclk <= '0';
		wait for clk_period/2;
		mclk <= '1';
		wait for clk_period/2;
	end process;
	
	stim_process: process
	begin
		puc_rst <= '1';
		wait for clk_period;
		puc_rst <= '0';
		wait for clk_period*2;
		per_en <= '1';
		per_addr <= std_logic_vector(to_unsigned(16#190#, PER_MSB+1));
		per_we <= "11";
		per_din <= x"AAAA";
		wait for clk_period*2;
		per_we <= "00";
		per_din <= x"F0F0";
		wait for clk_period*2;
		per_en <= '0';
		wait;
	end process;
	
end architecture;