-- 16 bit peripheral template in VHDL for openMSP430

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

use work.config.all;

entity template_periph_16b is 
	generic (
		-- Decoder bit width (defines how many bits are considered for address decoding)
		DEC_WD : natural := 3;
		-- Register base address (must be aligned to decoder bit width)
		BASE_ADDR :natural := 16#190#
	);
	port (
		per_dout :  out std_logic_vector(15 downto 0);
		mclk :  in std_logic;
		per_addr :  in std_logic_vector( PER_MSB downto 0 );
		per_din :  in std_logic_vector(15 downto 0);
		per_en :  in std_logic;
		per_we :  in std_logic_vector( 1 downto 0 );
		puc_rst :  in std_logic
	);
end entity; 

architecture rtl of template_periph_16b is
	constant BASE_ADDR_SLV : std_logic_vector( PER_MSB downto 0 ) := std_logic_vector(to_unsigned(BASE_ADDR, PER_MSB+1));
	signal local_addr: unsigned(DEC_WD -2 downto 0) := unsigned(per_addr(DEC_WD -1 downto 1)); -- aligned to 16bit data width
	
	signal reg_sel : std_logic;

	constant DEC_SZ : natural := 2**(DEC_WD-1);	-- Decoder size/number of registers
	signal reg_dec : unsigned( ( DEC_SZ - 1 ) downto 0 );
	signal reg_wr : unsigned( ( DEC_SZ - 1 ) downto 0 );
	signal reg_rd : unsigned( ( DEC_SZ - 1 ) downto 0 );
	
	-- registers
	type t_Register is array(0 to (DEC_SZ - 1) ) of unsigned(per_din'range);
	signal Cntrl : t_Register;
	signal Cntrl_rd : t_Register;

begin
	-- Test if this peripheral is addressed
	reg_sel <= per_en when ( per_addr(PER_MSB downto DEC_WD ) = BASE_ADDR_SLV(PER_MSB downto DEC_WD) )
				else '0';
	
	g_reg1: for i in 0 to (DEC_SZ -1 ) generate
		-- Address decoder
		reg_dec(i) <= '1' when (to_integer(local_addr) = i) else '0';
		reg_wr(i) <= (reg_sel and (per_we(0) or per_we(1))) when (to_integer(local_addr) = i) else '0';
		reg_rd(i) <= reg_sel when (to_integer(local_addr) = i) else '0';
	
		p_reg1: process begin
			wait until (rising_edge(mclk));
			
			if ( puc_rst = '1' ) then -- synchronous reset
				Cntrl(i) <= (Cntrl(i)'range => '0') ;
			else 
				if ( reg_wr(i) = '1' ) then 
					Cntrl(i) <= unsigned(per_din);
				end if;
			end if;
		end process;
		
		-- Output mux
		Cntrl_rd(i) <= Cntrl(i) when (reg_rd(i) = '1') else (Cntrl_rd(i)'range => '0');
	end generate;

	per_dout <=  std_logic_vector(Cntrl_rd(to_integer(local_addr)));
end architecture rtl; 

