-- 16 bit peripheral template
-- 	based on template_periph_16b.v

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity template_periph_16b is 
	generic (
		-- Register base address (must be aligned to decoder bit width)
		BASE_ADDR : std_logic_vector( 14 downto 0 ) := x"0190" ;
		-- Decoder bit width (defines how many bits are considered for address decoding)
		DEC_WD : std_logic_vector := 3
   );
	port (
		per_we :  in std_logic_vector( 1 downto 0 );
		per_en :  in std_logic;
		per_dout :  out std_logic_vector( per_dout'range ) := ( cntrl1_rd or cntrl2_rd or cntrl3_rd or cntrl4_rd ) ;
		mclk :  in std_logic;
		per_addr :  in std_logic_vector( 13 downto 0 );
		per_din :  in std_logic_vector( per_dout'range );
		puc_rst :  in std_logic
	);
end entity; 

architecture rtl of template_periph_16b is
	-- Register one-hot decoder utilities
	constant DEC_SZ : std_logic_vector := (1 sll DEC_WD) ;
	constant BASE_REG : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := ( ( DEC_SZ - 1 ) downto 1 => '0', 0 => '1');
	-- Register addresses offset
	constant CNTRL1 : std_logic_vector( ( DEC_WD - 1 ) downto 0 ) := x"0" ;
	constant CNTRL2 : std_logic_vector( ( DEC_WD - 1 ) downto 0 ) := x"2" ;
	constant CNTRL3 : std_logic_vector( ( DEC_WD - 1 ) downto 0 ) := x"4" ;
	constant CNTRL4 : std_logic_vector( ( DEC_WD - 1 ) downto 0 ) := x"6";
	-- Register one-hot decoder
	constant CNTRL1_D : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := ( BASE_REG sll CNTRL1 );
	constant CNTRL2_D : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := ( BASE_REG sll CNTRL2 );
	constant CNTRL3_D : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := ( BASE_REG sll CNTRL3 );
	constant CNTRL4_D : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := ( BASE_REG sll CNTRL4 );
	
	-- Local register selection
	signal reg_sel : std_logic := ( per_en and ( per_addr(per_addr'left downto ( DEC_WD - 1 ) ) = BASE_ADDR(BASE_ADDR'left downto DEC_WD) ) ) ;
	-- Register local address
	signal reg_addr : std_logic_vector( ( DEC_WD - 1 ) downto 0 ) := ( per_addr(( DEC_WD - 2 ) downto 0 ) & '0' );
	-- Register address decode
	signal reg_dec : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := ( ( CNTRL1_D and ( others => ( reg_addr = CNTRL1 ) ) )
			or ( CNTRL2_D and ( others => ( reg_addr = CNTRL2 ) ) )
			or ( CNTRL3_D and ( others => ( reg_addr = CNTRL3 ) ) )
			or ( CNTRL4_D and ( others => ( reg_addr = CNTRL4 ) ) ) );
	-- Read/Write probes
	signal reg_write : std_logic := ( OR_REDUCE( per_we ) and reg_sel ) ;
	signal reg_read : std_logic := ( NOR_REDUCE( per_we ) and reg_sel ) ;
	-- Read/Write vectors
	signal reg_wr : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := ( reg_dec and ( others => reg_write ) ) ;
	signal reg_rd : std_logic_vector( ( DEC_SZ - 1 ) downto 0 ) := ( reg_dec and ( others => reg_read ) ) ;
 	 
	signal cntrl1 : std_logic_vector( per_dout'range );
	signal cntrl1_wr : std_logic := reg_wr(CNTRL1);
	signal cntrl1_rd : std_logic_vector( per_dout'range ) := ( cntrl1 and ( others => reg_rd(CNTRL1) ) ) ;
	  
	signal cntrl2 : std_logic_vector( per_dout'range );
	signal cntrl2_wr : std_logic := reg_wr(CNTRL2);
	signal cntrl2_rd : std_logic_vector( per_dout'range ) := ( cntrl2 and ( others => reg_rd(CNTRL2) ) ) ;
	 
	signal cntrl3 : std_logic_vector( per_dout'range );
	signal cntrl3_wr : std_logic := reg_wr(CNTRL3);
	signal cntrl3_rd : std_logic_vector( per_dout'range ) := ( cntrl3 and ( others => reg_rd(CNTRL3) ) ) ;
	
	signal cntrl4 : std_logic_vector( per_dout'range );
	signal cntrl4_wr : std_logic := reg_wr(CNTRL4);
	signal cntrl4_rd : std_logic_vector( per_dout'range ) := ( cntrl4 and ( others => reg_rd(CNTRL4) ) ) ;

begin 
	process begin
		wait until (rising_edge(mclk)); -- (puc_rst treated as synced)
		
		if ( puc_rst ) then 
			cntrl1 <= X"0000" ;
		else 
			if ( cntrl1_wr ) then 
				cntrl1 <= per_din;
			end if;
		end if;
	end process;
	
	process begin
		wait until (rising_edge(mclk)); -- (puc_rst treated as synced)
		
		if ( puc_rst ) then 
			cntrl2 <= X"0000" ;
		else 
			if ( cntrl2_wr ) then 
				cntrl2 <= per_din;
			end if;
		end if;
	end process;
	
	process begin
		wait until (rising_edge(mclk)); -- (puc_rst treated as synced)
		
		if ( puc_rst ) then 
			cntrl3 <= X"0000" ;
		else 
			if ( cntrl3_wr ) then 
				cntrl3 <= per_din;
			end if;
		end if;
	end process;
	
	process begin
		wait until (rising_edge(mclk)); -- (puc_rst treated as synced)
		
		if ( puc_rst ) then 
			cntrl4 <= X"0000" ;
		else 
			if ( cntrl4_wr ) then 
				cntrl4 <= per_din;
			end if;
		end if;
	end process;
end; 


