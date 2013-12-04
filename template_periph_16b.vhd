-- 16 bit peripheral template
-- 	modelled in VHDL after template_periph_16b.v of the openMSP430 project
--		this code should be seen more as Verilog to VHDL conversion example,
--		as a real-world implementation

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
	constant BASE_ADDR_SLV : std_logic_vector( PER_MSB + 1 downto 0 ) := std_logic_vector(to_unsigned(BASE_ADDR, PER_MSB+2));
	-- Register addresses offset
	constant CNTRL1_O : natural range 0 to 2**DEC_WD - 1 := 16#0# ;
	constant CNTRL2_O : natural range 0 to 2**DEC_WD - 1 := 16#2# ;
	constant CNTRL3_O : natural range 0 to 2**DEC_WD - 1 := 16#4# ;
	constant CNTRL4_O : natural range 0 to 2**DEC_WD - 1 := 16#6# ;
	-- Register one-hot decoder utilities
	constant DEC_SZ : natural := 2**DEC_WD ;
	constant BASE_REG : unsigned( ( DEC_SZ - 1 ) downto 0 ) := ( ( DEC_SZ - 1 ) downto 1 => '0', 0 => '1');
	-- Register one-hot decoder
	constant CNTRL1_D : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := std_logic_vector( BASE_REG sll CNTRL1_O );
	constant CNTRL2_D : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := std_logic_vector( BASE_REG sll CNTRL2_O );
	constant CNTRL3_D : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := std_logic_vector( BASE_REG sll CNTRL3_O );
	constant CNTRL4_D : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := std_logic_vector( BASE_REG sll CNTRL4_O );
	
	-- Local register selection
	signal reg_sel : std_logic;
	-- Register local address
	signal reg_addr : std_logic_vector( ( DEC_WD - 1 ) downto 0 ) := ( per_addr(( DEC_WD - 2 ) downto 0 ) & '0' );
	-- Register address decode
	signal reg_dec : std_logic_vector( ( DEC_SZ - 1 ) downto 0 );
	-- Read/Write probes
	signal reg_write : std_logic := (( per_we(1) or per_we(1)) and reg_sel ) ;
	signal reg_read : std_logic := ( not( per_we(1) or per_we(1)) and reg_sel ) ;
	-- Read/Write vectors
	signal reg_wr : std_logic_vector( ( DEC_SZ - 1 ) downto 0 );
	signal reg_rd : std_logic_vector( ( DEC_SZ - 1 ) downto 0 );
 	 
	signal cntrl1 : std_logic_vector( per_dout'range );
	signal cntrl1_wr : std_logic;
	signal cntrl1_rd : std_logic_vector( per_dout'range );
	  
	signal cntrl2 : std_logic_vector( per_dout'range );
	signal cntrl2_wr : std_logic;
	signal cntrl2_rd : std_logic_vector( per_dout'range );
	 
	signal cntrl3 : std_logic_vector( per_dout'range );
	signal cntrl3_wr : std_logic;
	signal cntrl3_rd : std_logic_vector( per_dout'range );
	
	signal cntrl4 : std_logic_vector( per_dout'range );
	signal cntrl4_wr : std_logic;
	signal cntrl4_rd : std_logic_vector( per_dout'range );

begin
	-- Local register selection
	reg_sel <= per_en when ( per_addr(per_addr'left downto ( DEC_WD - 1 ) ) = BASE_ADDR_SLV(BASE_ADDR_SLV'left downto DEC_WD) ) else '0' ;
	-- Register address decode
	reg_dec <= 	CNTRL1_D when (reg_addr = CNTRL1) else
					CNTRL2_D when (reg_addr = CNTRL2) else
					CNTRL3_D when (reg_addr = CNTRL3) else
					CNTRL4_D when (reg_addr = CNTRL4) else
					(reg_dec'range => '0');
	
	-- Read/Write vectors
	reg_wr <= ( reg_dec and ( reg_wr'range => reg_write ) ) ;
	reg_rd <= ( reg_dec and ( reg_rd'range => reg_read ) ) ;
 	 
	-- CNTRL1 Register
	cntrl1_wr <= reg_wr(CNTRL1_O);

	PROC_CNTRL1: process begin
		wait until (rising_edge(mclk));
		
		if ( puc_rst ) then -- synchronous reset
			cntrl1 <= X"0000" ;
		else 
			if ( cntrl1_wr ) then 
				cntrl1 <= per_din;
			end if;
		end if;
	end process;

	-- CNTRL2 Register
	cntrl2_wr <= reg_wr(CNTRL2_O);
		
	PROC_CNTRL2: process begin
		wait until (rising_edge(mclk));
		
		if ( puc_rst ) then -- synchronous reset
			cntrl2 <= X"0000" ;
		else 
			if ( cntrl2_wr ) then 
				cntrl2 <= per_din;
			end if;
		end if;
	end process;

	-- CNTRL3 Register
	cntrl3_wr <= reg_wr(CNTRL3_O);
	
	PROC_CNTRL3: process begin
		wait until (rising_edge(mclk));
		
		if ( puc_rst ) then -- synchronous reset
			cntrl3 <= X"0000" ;
		else 
			if ( cntrl3_wr ) then 
				cntrl3 <= per_din;
			end if;
		end if;
	end process;

	-- CNTRL4 Register
	cntrl4_wr <= reg_wr(CNTRL4_O);
	
	PROC_CNTRL4: process begin
		wait until (rising_edge(mclk));
		
		if ( puc_rst ) then -- synchronous reset
			cntrl4 <= X"0000" ;
		else 
			if ( cntrl4_wr ) then 
				cntrl4 <= per_din;
			end if;
		end if;
	end process;
	
	-- DATA OUTPUT GENERATION
		
	-- Data output mux
	cntrl1_rd <= ( cntrl1 and ( per_dout'range => reg_rd(CNTRL1_O) ) ) ;
	cntrl2_rd <= ( cntrl2 and ( per_dout'range => reg_rd(CNTRL2_O) ) ) ;	
	cntrl3_rd <= ( cntrl3 and ( per_dout'range => reg_rd(CNTRL3_O) ) ) ;
	cntrl4_rd <= ( cntrl4 and ( per_dout'range => reg_rd(CNTRL4_O) ) ) ;

	per_dout <=  ( cntrl1_rd or cntrl2_rd or cntrl3_rd or cntrl4_rd ) ;
end; 


