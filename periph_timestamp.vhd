-- timestamp peripheral for openMSP430
-- 	this instantiates timestamp component (needed for qcounters component) from HostMot2

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

use work.config.all;

entity periph_timestamp is 
	generic (
		-- Decoder bit width (defines how many bits are considered for address decoding)
		DEC_WD : natural := 1;
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
end entity; 

architecture rtl of periph_timestamp is
	-- timestamp component from hostmot2
	component timestamp is
   port (
		ibus : in std_logic_vector(15 downto 0);
		obus : out std_logic_vector(15 downto 0);
		loadtsdiv : in std_logic;
		readts : in std_logic;
		readtsdiv : in std_logic;
		tscount : out std_logic_vector (15 downto 0);
		clk : in std_logic);
	end component timestamp;

	constant BASE_ADDR_SLV : std_logic_vector( PER_MSB+1 downto 0 ) := std_logic_vector(to_unsigned(BASE_ADDR, PER_MSB+2));
	signal local_addr: unsigned(DEC_WD -1 downto 0);
	
	signal reg_sel : std_logic;

	constant DEC_SZ : natural := 2**(DEC_WD-1);	-- Decoder size/number of registers
	signal reg_dec : unsigned( ( DEC_SZ - 1 ) downto 0 );
	signal reg_wr : unsigned( ( DEC_SZ - 1 ) downto 0 );
	signal reg_rd : unsigned( ( DEC_SZ - 1 ) downto 0 );
	
  signal ts: std_logic_vector (15 downto 0);

	-- timestamp component signals
	signal ibus : std_logic_vector(15 downto 0);
	signal obus : std_logic_vector(15 downto 0);
	alias loadtsdiv : std_logic is reg_wr(1);
	alias readts : std_logic is reg_rd(0);
	alias readtsdiv : std_logic is reg_rd(1);
begin
	-- Test if this peripheral is addressed
	reg_sel <= per_en when ( per_addr(PER_MSB downto DEC_WD ) = BASE_ADDR_SLV(PER_MSB+1 downto DEC_WD+1) )
				else '0';

	local_addr <= unsigned(per_addr(DEC_WD -1 downto 0)); -- 16bit data width, so cut off LSB
	
	g_reg1: for i in 0 to (DEC_SZ -1 ) generate
		-- Address decoder
		reg_dec(i) <= '1' when (to_integer(local_addr) = i) else '0';
		reg_wr(i) <= (reg_sel and    (per_we(0) or per_we(1))) when (to_integer(local_addr) = i) else '0';
		reg_rd(i) <= (reg_sel and not(per_we(0) or per_we(1))) when (to_integer(local_addr) = i) else '0';
	end generate;

	per_dout <=  per_din when (per_we(0)='1' or per_we(1)='1') else 	-- mirror per_in to per_out on write ops TODO: needed?
			ts when (reg_rd(0) = '1') else
			obus when (reg_rd(1) = '1') else
			(others => '0');
			
	-- timestamp entity instantiation
	inst_timestamp : timestamp
		port map
		(
			ibus => ibus,
			obus => obus,
			loadtsdiv => loadtsdiv,
			readts => readts,
			readtsdiv => readtsdiv,
			tscount => ts,
			clk => mclk
		);
	
    ibus <= per_din when (reg_sel='1') else 
				(others => '0');
				
	tscount <= ts;
end architecture rtl; 

