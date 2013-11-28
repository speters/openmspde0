-- VHDL module to instantiate the openMSP430 Verilog code
-- by Soenke J. Peters
--
-- openMSP430 uses the Verilog preprocessor,
-- so configuration has to be done in both VHDL, and Verilog code
-- until someone has a better approach.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config.all;

entity openMSP430_fpga_top is
	port (
		CLOCK_50 	: in std_logic;
		--//////////// LED //////////
		LED			: out std_logic_vector(7 downto 0);
		--//////////// KEY //////////
		KEY			: in std_logic_vector(1 downto 0);
		--//////////// SWitch //////////
		SW				: in std_logic_vector(3 downto 0);
		--//////////// SDRAM //////////
		DRAM_ADDR	  : out std_logic_vector(12 downto 0);
		DRAM_BA 		: out std_logic_vector(1 downto 0);
		DRAM_CAS_N 	: out std_logic;
		DRAM_CKE 	  : out std_logic;
		DRAM_CLK 	  : out std_logic;
		DRAM_CS_N 	: out std_logic;
		DRAM_DQ 		:  buffer std_logic_vector(15 downto 0);
		DRAM_DQM 	  : out std_logic_vector(1 downto 0);
		DRAM_RAS_N 	: out std_logic;
		DRAM_WE_N 	: out std_logic;

		--//////////// EPCS //////////
		EPCS_ASDO 	: out std_logic;	-- Serial data output
		EPCS_DATA0 	: in std_logic;	-- Serial data input
		EPCS_DCLK 	: out std_logic;	-- Serial interface clock output
		EPCS_NCSO 	: out std_logic;

		--//////////// Accelerometer and EEPROM //////////
		G_SENSOR_CS_N : out std_logic;
		G_SENSOR_INT  : in std_logic;
		I2C_SCLK 	  : out std_logic;
		I2C_SDAT 	  : inout std_logic;

		--//////////// ADC //////////
		ADC_CS_N 	: out std_logic;
		ADC_SADDR 	: out std_logic;
		ADC_SCLK 	: out std_logic;
		ADC_SDAT 	: in std_logic;

		--//////////// GPIO //////////
		-- //////////// upper GPIO header //////////
		GPIO_0		: inout std_logic_vector(33 downto 0);
		GPIO_0_IN 	: in std_logic_vector(1 downto 0);

		-- //////////// lower GPIO header //////////			
		GPIO_1		: out std_logic_vector(33 downto 0);	  
		GPIO_1_IN 	: in std_logic_vector(1 downto 0);

		-- //////////// 2x13 GPIO header //////////
		GPIO_2 		  : inout std_logic_vector(12 downto 0);
		GPIO_2_IN 	: in std_logic_vector(2 downto 0)
	);
end openMSP430_fpga_top;

architecture RTL of openMSP430_fpga_top is
	component openMSP430 is
		generic (
			INST_NR  : integer range 0 to 255 := 0; -- Current oMSP instance number     (for multicore systems)
			TOTAL_NR : integer range 0 to 255 := 0  -- Total number of oMSP instances-1 (for multicore systems)
		);
		port (
			-- OUTPUTs
			aclk	: out std_logic;	-- ASIC ONLY: ACLK
			aclk_en	: out std_logic;	-- FPGA ONLY: ACLK enable
			dbg_freeze	: out std_logic;	-- Freeze peripherals
			dbg_i2c_sda_out	: out std_logic;	-- Debug interface: I2C SDA OUT
			dbg_uart_txd	: out std_logic;	-- Debug interface: UART TXD
			dco_enable	: out std_logic;	-- ASIC ONLY: Fast oscillator enable
			dco_wkup	: out std_logic;	-- ASIC ONLY: Fast oscillator wake-up (asynchronous)
			dmem_addr	: out std_logic_vector(DMEM_MSB downto 0);	-- Data Memory address
			dmem_cen	: out std_logic;	-- Data Memory chip enable (low active)
			dmem_din	: out std_logic_vector(15 downto 0);	-- Data Memory data input
			dmem_wen	: out std_logic_vector(1 downto 0);	-- Data Memory write enable (low active)
			irq_acc	: out std_logic_vector(13 downto 0);	-- interrupt request accepted (one-hot signal)
			lfxt_enable	: out std_logic;	-- ASIC ONLY: Low frequency oscillator enable
			lfxt_wkup	: out std_logic;	-- ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
			mclk	: out std_logic;	-- main system clock
			per_addr	: out std_logic_vector(PER_MSB downto 0);	-- Peripheral address
			per_din	: out std_logic_vector(15 downto 0);	-- Peripheral data input
			per_we	: out std_logic_vector(1 downto 0);	-- Peripheral write enable (high active)
			per_en	: out std_logic;	-- Peripheral enable (high active)
			pmem_addr	: out std_logic_vector(PMEM_MSB downto 0);	-- Program Memory address
			pmem_cen	: out std_logic;	-- Program Memory chip enable (low active)
			pmem_din	: out std_logic_vector(15 downto 0);	-- Program Memory data input (optional)
			pmem_wen	: out std_logic_vector(1 downto 0);	-- Program Memory write enable (low active) (optional)
			puc_rst	: out std_logic;	-- main system reset
			smclk	: out std_logic;	-- ASIC ONLY: SMCLK
			smclk_en	: out std_logic;	-- FPGA ONLY: SMCLK enable

			-- INPUTs
			cpu_en	: in  std_logic;	-- Enable CPU code execution (asynchronous and non-glitchy)
			dbg_en	: in  std_logic;	-- Debug interface enable (asynchronous and non-glitchy)
			dbg_i2c_addr	: in  std_logic_vector(6 downto 0);	-- Debug interface: I2C Address
			dbg_i2c_broadcast	: in  std_logic_vector(6 downto 0);	-- Debug interface: I2C Broadcast Address (for multicore systems)
			dbg_i2c_scl	: in  std_logic;	-- Debug interface: I2C SCL
			dbg_i2c_sda_in	: in  std_logic;	-- Debug interface: I2C SDA in
			dbg_uart_rxd	: in  std_logic;	-- Debug interface: UART RXD (asynchronous)
			dco_clk	: in  std_logic;	-- Fast oscillator (fast clock)
			dmem_dout	: in  std_logic_vector(15 downto 0);	-- Data Memory data output
			irq	: in  std_logic_vector(13 downto 0);	-- Maskable interrupts (14, 30 or 62)
			lfxt_clk	: in  std_logic;	-- Low frequency oscillator (typ 32kHz)
			nmi	: in  std_logic;	-- Non-maskable interrupt (asynchronous and non-glitchy)
			per_dout	: in  std_logic_vector(15 downto 0);	-- Peripheral data output
			pmem_dout	: in  std_logic_vector(15 downto 0);	-- Program Memory data output
			reset_n	: in  std_logic;	-- Reset Pin (active low, asynchronous and non-glitchy)
			scan_enable	: in  std_logic;	-- ASIC ONLY: Scan enable (active during scan shifting)
			scan_mode	: in  std_logic;	-- ASIC ONLY: Scan mode
			wkup	: in  std_logic 	-- ASIC ONLY: System Wake-up (asynchronous and non-glitchy)
		);
	end component openMSP430;

	component omsp_gpio is
		generic (
			P1_EN, 
			P2_EN,
			P3_EN,
			P4_EN,
			P5_EN,
			P6_EN	: integer
		);
		port (
			-- OUTPUTs
			irq_port1	: out std_logic;								-- Port 1 interrupt
			irq_port2	: out std_logic;								-- Port 2 interrupt
			p1_dout		: out  std_logic_vector(7 downto 0);	-- Port 1 data output
			p1_dout_en	: out  std_logic_vector(7 downto 0);	-- Port 1 data output enable
			p1_sel		: out  std_logic_vector(7 downto 0);	-- Port 1 function select	
			p2_dout		: out  std_logic_vector(7 downto 0);	-- Port 2 data output
			p2_dout_en	: out  std_logic_vector(7 downto 0);	-- Port 2 data output enable
			p2_sel		: out  std_logic_vector(7 downto 0);	-- Port 2 function select
			p3_dout		: out  std_logic_vector(7 downto 0);	-- Port 3 data output
			p3_dout_en	: out  std_logic_vector(7 downto 0);	-- Port 3 data output enable
			p3_sel		: out  std_logic_vector(7 downto 0);	-- Port 3 function select	
			p4_dout		: out  std_logic_vector(7 downto 0);	-- Port 4 data output
			p4_dout_en	: out  std_logic_vector(7 downto 0);	-- Port 4 data output enable
			p4_sel		: out  std_logic_vector(7 downto 0);	-- Port 4 function select
			p5_dout		: out  std_logic_vector(7 downto 0);	-- Port 5 data output
			p5_dout_en	: out  std_logic_vector(7 downto 0);	-- Port 5 data output enable
			p5_sel		: out  std_logic_vector(7 downto 0);	-- Port 5 function select
			p6_dout		: out  std_logic_vector(7 downto 0);	-- Port 6 data output
			p6_dout_en	: out  std_logic_vector(7 downto 0);	-- Port 6 data output enable
			p6_sel		: out  std_logic_vector(7 downto 0);	-- Port 6 function select		
			per_dout		: out std_logic_vector(15 downto 0);	-- Peripheral data output
			
			-- INPUTs
			mclk		: in std_logic;							-- main system clock
			p1_din	: in std_logic_vector(7 downto 0);	-- Port 1 data input
			p2_din	: in std_logic_vector(7 downto 0);	-- Port 2 data input
			p3_din	: in std_logic_vector(7 downto 0);	-- Port 3 data input
			p4_din	: in std_logic_vector(7 downto 0);	-- Port 4 data input
			p5_din	: in std_logic_vector(7 downto 0);	-- Port 5 data input
			p6_din	: in std_logic_vector(7 downto 0);	-- Port 6 data input
			per_addr	: in std_logic_vector(PER_MSB downto 0);	-- Peripheral address
			per_din	: in std_logic_vector(15 downto 0); -- Peripheral data input
			per_en	: in std_logic;							-- Peripheral enable (high active)
			per_we	: in std_logic_vector(1 downto 0);	-- Peripheral write enable (high active)
			puc_rst	: in std_logic								-- main system reset
		);
	end component;

	component omsp_timerA is
		port (
			-- OUTPUTs
		  irq_ta0 : out std_logic;    -- Timer A interrupt: TACCR0
        irq_ta1 : out std_logic;    -- Timer A interrupt: TAIV, TACCR1, TACCR2
        per_dout    : out std_logic_vector(15 downto 0);    -- Peripheral data output
        ta_out0 : out std_logic;    -- Timer A output 0
        ta_out0_en  : out std_logic;    -- Timer A output 0 enable
        ta_out1 : out std_logic;    -- Timer A output 1
        ta_out1_en  : out std_logic;    -- Timer A output 1 enable
        ta_out2 : out std_logic;    -- Timer A output 2
        ta_out2_en  : out std_logic;    -- Timer A output 2 enable

			-- INPUTs
        aclk_en : in  std_logic;    -- ACLK enable (from CPU)
        dbg_freeze  : in  std_logic;    -- Freeze Timer A counter
        inclk   : in  std_logic;    -- inCLK external timer clock (SLOW)
        irq_ta0_acc : in  std_logic;    -- interrupt request TACCR0 accepted
        mclk    : in  std_logic;    -- main system clock
        per_addr    : in  std_logic_vector(PER_MSB downto 0);    -- Peripheral address
        per_din : in  std_logic_vector(15 downto 0);    -- Peripheral data input
        per_en  : in  std_logic;    -- Peripheral enable (high active)
        per_we  : in  std_logic_vector(1 downto 0); -- Peripheral write enable (high active)
        puc_rst : in  std_logic;    -- main system reset
        smclk_en    : in  std_logic;    -- SMCLK enable (from CPU)
        ta_cci0a    : in  std_logic;    -- Timer A capture 0 input A
        ta_cci0b    : in  std_logic;    -- Timer A capture 0 input B
        ta_cci1a    : in  std_logic;    -- Timer A capture 1 input A
        ta_cci1b    : in  std_logic;    -- Timer A capture 1 input B
        ta_cci2a    : in  std_logic;    -- Timer A capture 2 input A
        ta_cci2b    : in  std_logic;    -- Timer A capture 2 input B
        taclk   : in  std_logic     -- TACLK external timer clock (SLOW)
		);
	end component;

	-- Simple full duplex UART (8N1 protocol)
	component omsp_uart is
		generic (
			BASE_ADDR : inTEGER := 128 ; -- 16#0080# --	Register base address (must be aligned to decoder bit width)
			DEC_WD : inTEGER := 3	-- Decoder bit width (defines how many bits are considered for address decoding)
		);
		port (
			-- OUTPUTs
			irq_uart_rx :  out std_logic;	-- UART receive interrupt
			irq_uart_tx :  out std_logic;	-- UART transmit interrupt
			per_dout :  out std_logic_vector( 15  downto 0  );	-- Peripheral data output
			uart_txd :  out std_logic;	-- UART Data Transmit (TXD)
			-- INPUTs
			mclk :  in std_logic;	-- main system clock
			per_addr :  in std_logic_vector(PER_MSB  downto 0  );	-- Peripheral address
			per_din :  in std_logic_vector( 15  downto 0  );	-- Peripheral data input
			per_en :  in std_logic;	-- Peripheral enable (high active)
			per_we :  in std_logic_vector( 1  downto 0  );	-- Peripheral write enable (high active)
			puc_rst :  in std_logic;	-- main system reset
			smclk_en :  in std_logic;	-- SMCLK enable (from CPU)
			uart_rxd :  in std_logic	-- UART Data Receive (RXD)
		);
	end component;

	component io_mux is
		generic (WIDTH : natural := 8);
		port (
			-- Function A (typically GPIO)
			a_din : out std_logic_vector(WIDTH -1 downto 0);
			a_dout : in std_logic_vector(WIDTH -1 downto 0);
			a_dout_en : in std_logic_vector(WIDTH -1 downto 0);
			-- Function B (Timer A, ...)
			b_din : out std_logic_vector(WIDTH -1 downto 0);
			b_dout : in std_logic_vector(WIDTH -1 downto 0);
			b_dout_en : in std_logic_vector(WIDTH -1 downto 0);
			-- IO Cell
			io_din : in std_logic_vector(WIDTH -1 downto 0);
			io_dout : out std_logic_vector(WIDTH -1 downto 0);
			io_dout_en : out std_logic_vector(WIDTH -1 downto 0);
			-- Function selection (0=A, 1=B)
			sel : in std_logic_vector(WIDTH -1 downto 0)
		);
	end component;

	component dmem0 is
		-- MegaWizard 1-Port RAM: Which ports should be registered? 'q' output port?: NO!!!
		port
		(
			address	: in std_logic_vector (DMEM_MSB downto 0);
			clken		: in std_logic  := '1';
			clock		: in std_logic  := '1';
			data		: in std_logic_vector (15 downto 0);
			wren		: in std_logic ;
			byteena	: in std_logic_vector (1 downto 0);
			q			: out std_logic_vector (15 downto 0)
		);
	end component dmem0;

	component pmem0 is
		-- MegaWizard 1-Port RAM: Which ports should be registered? 'q' output port?: NO!!!
		port
		(
			address	: in std_logic_vector (PMEM_MSB downto 0);
			clken		: in std_logic  := '1';
			clock		: in std_logic  := '1';
			data		: in std_logic_vector (15 downto 0);
			wren		: in std_logic ;
			byteena	: in std_logic_vector (1 downto 0);
			q			: out std_logic_vector (15 downto 0)
		);
	end component pmem0;

--////////////////////--        Clock input        /////////////
	-- overall clock
	signal clk_sys	: std_logic;

	--=============================================================================
	-- 1)  inTERNAL WIRES/REGISTERS/PARAMETERS DECLARATION
	--=============================================================================

	-- openMSP430 output buses
	signal per_addr	: std_logic_vector(PER_MSB downto 0);
	signal per_din		: std_logic_vector(15 downto 0);
	signal per_we		: std_logic_vector(1 downto 0);
	signal dmem_addr	: std_logic_vector(DMEM_MSB downto 0);
	signal dmem_din	: std_logic_vector(15 downto 0);
	signal dmem_wen	: std_logic_vector(1 downto 0);
	signal dmem_cen	: std_logic;
	signal pmem_addr	: std_logic_vector(PMEM_MSB downto 0);
	signal pmem_din	: std_logic_vector(15 downto 0);
	signal pmem_wen	: std_logic_vector(1 downto 0);
	signal pmem_cen	: std_logic;
	signal irq_acc		: std_logic_vector(13 downto 0);
	
	-- openMSP430 input buses
	signal irq_bus		: std_logic_vector(13 downto 0);
	signal per_dout	: std_logic_vector(15 downto 0);
	signal dmem_dout	: std_logic_vector(15 downto 0);
	signal pmem_dout	: std_logic_vector(15 downto 0);

	-- Others
	signal reset_n		: std_logic;
	signal puc_rst		: std_logic;
	signal mclk			: std_logic;
	signal smclk_en 	: std_logic;
	signal aclk_en 	: std_logic;
	signal nmi 			: std_logic;
	signal dbg_uart_rxd, dbg_uart_txd, dbg_freeze : std_logic;

	-- GPIO
	signal p1_din	: std_logic_vector(7 downto 0);
	signal p1_dout	: std_logic_vector(7 downto 0);
	signal p1_dout_en	: std_logic_vector(7 downto 0);
	signal p1_sel	: std_logic_vector(7 downto 0);
	signal p2_din	: std_logic_vector(7 downto 0);
	signal p2_dout	: std_logic_vector(7 downto 0);
	signal p2_dout_en	: std_logic_vector(7 downto 0);
	signal p2_sel	: std_logic_vector(7 downto 0);
	signal p3_din	: std_logic_vector(7 downto 0);
	signal p3_dout	: std_logic_vector(7 downto 0);
	signal p3_dout_en	: std_logic_vector(7 downto 0);
	signal p3_sel	: std_logic_vector(7 downto 0);
	signal per_dout_dio	: std_logic_vector(15 downto 0);

	-- Timer A
	signal irq_ta0 : std_logic;    -- Timer A interrupt: TACCR0
	signal irq_ta1 : std_logic;    -- Timer A interrupt: TAIV, TACCR1, TACCR2
	signal per_dout_tA    : std_logic_vector(15 downto 0);    -- Peripheral data output
	signal ta_out0 : std_logic;    -- Timer A output 0
	signal ta_out0_en  : std_logic;    -- Timer A output 0 enable
	signal ta_out1 : std_logic;    -- Timer A output 1
	signal ta_out1_en  : std_logic;    -- Timer A output 1 enable
	signal ta_out2 : std_logic;    -- Timer A output 2
	signal ta_out2_en  : std_logic;    -- Timer A output 2 enable
	
	signal ta_cci0a    : std_logic;    -- Timer A capture 0 input A
	signal ta_cci0b    : std_logic;    -- Timer A capture 0 input B
	signal ta_cci1a    : std_logic;    -- Timer A capture 1 input A
--	signal ta_cci1b    : std_logic;    -- Timer A capture 1 input B
	signal ta_cci2a    : std_logic;    -- Timer A capture 2 input A
--	signal ta_cci2b    : std_logic;    -- Timer A capture 2 input B
	signal taclk   : std_logic;    -- TACLK external timer clock (SLOW)
	
	signal inclk : std_logic;

	-- GPIO Function selection
	signal p1_io_mux_b_unconnected	: std_logic_vector(7 downto 0);
	signal p1_io_dout	: std_logic_vector(7 downto 0);
	signal p1_io_dout_en	: std_logic_vector(7 downto 0);
	signal p1_io_din	: std_logic_vector(7 downto 0);
	signal p1_b_din : std_logic_vector(7 downto 0);

	signal p2_io_mux_b_unconnected	: std_logic_vector(7 downto 0);
	signal p2_io_dout	: std_logic_vector(7 downto 0);
	signal p2_io_dout_en	: std_logic_vector(7 downto 0);
	signal p2_io_din	: std_logic_vector(7 downto 0);
	signal p2_b_din : std_logic_vector(7 downto 0);
	
	signal irq_port1, irq_port2 : std_logic;
	
	signal per_en : std_logic;
	
	-- Simple UART
	signal irq_uart_rx : std_logic;
	signal irq_uart_tx : std_logic;
	signal per_dout_uart : std_logic_vector(15 downto 0);
	signal hw_uart_txd : std_logic;
	signal hw_uart_rxd : std_logic;

begin
	-- All inout port turn to tri-state
	DRAM_DQ	<= (others => 'Z');
	I2C_SDAT	<= 'Z';
	GPIO_0	<= (others => 'Z');
	GPIO_1	<= (others => 'Z');

	-- SDRAM blocking
	DRAM_CS_N	<= '1';
	DRAM_CKE	<= '0';
	-- Other peripheral blocking
	EPCS_NCSO <= '1';
	G_SENSOR_CS_N <= '1';
	ADC_CS_N <= '1';

	clk_sys	<= CLOCK_50;

	reset_n	<= KEY(0);

	--=============================================================================
	-- 4)  OPENMSP430
	--=============================================================================
	openMSP430_0: openMSP430
	port map (
		-- OUTPUTs
		aclk            => open,             -- ASIC ONLY: ACLK
		aclk_en	=> aclk_en,		-- FPGA ONLY: ACLK enable
		dbg_freeze	=> dbg_freeze,		-- Freeze peripherals
		dbg_i2c_sda_out => open,             -- Debug interface: I2C SDA OUT
		dbg_uart_txd	=> dbg_uart_txd,		-- Debug interface: UART TXD
		dco_enable      => open,             -- ASIC ONLY: Fast oscillator enable
		dco_wkup        => open,             -- ASIC ONLY: Fast oscillator wake-up (asynchronous)
		dmem_addr	=> dmem_addr,		-- Data Memory address
		dmem_cen	=> dmem_cen,		-- Data Memory chip enable (low active)
		dmem_din	=> dmem_din,		-- Data Memory data input
		dmem_wen	=> dmem_wen,		-- Data Memory write enable (low active)
		irq_acc	=> irq_acc,		-- interrupt request accepted (one-hot signal)
		lfxt_enable     => open,             -- ASIC ONLY: Low frequency oscillator enable
		lfxt_wkup       => open,             -- ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
		mclk	=> mclk,		-- main system clock
		per_addr	=> per_addr,		-- Peripheral address
		per_din	=> per_din,		-- Peripheral data input
		per_we	=> per_we,		-- Peripheral write enable (high active)
		per_en	=> per_en,		-- Peripheral enable (high active)
		pmem_addr	=> pmem_addr,		-- Program Memory address
		pmem_cen	=> pmem_cen,		-- Program Memory chip enable (low active)
		pmem_din	=> pmem_din,		-- Program Memory data input (optional)
		pmem_wen	=> pmem_wen,		-- Program Memory write enable (low active) (optional)
		puc_rst	=> puc_rst,		-- main system reset
		smclk    	=> open,             -- ASIC ONLY: SMCLK
		smclk_en	=> open,		-- FPGA ONLY: SMCLK enable

		-- INPUTs
		cpu_en	=> '1',		-- Enable CPU code execution (asynchronous and non-glitchy)
		dbg_en	=> '1',		-- Debug interface enable (asynchronous and non-glitchy)
		dbg_i2c_addr	=> (others => '0'),		-- Debug interface: I2C Address
		dbg_i2c_broadcast	=> (others => '0'),		-- Debug interface: I2C Broadcast Address (for multicore systems)
		dbg_i2c_scl	=> '1',		-- Debug interface: I2C SCL
		dbg_i2c_sda_in	=> '1',		-- Debug interface: I2C SDA in
		dbg_uart_rxd	=> dbg_uart_rxd,		-- Debug interface: UART RXD (asynchronous)
		dco_clk	=> clk_sys,		-- Fast oscillator (fast clock)
		dmem_dout	=> dmem_dout,		-- Data Memory data output
		irq	=> irq_bus,		-- Maskable interrupts
		lfxt_clk	=> '0',		-- Low frequency oscillator (typ 32kHz)
		nmi	=> nmi,		-- Non-maskable interrupt (asynchronous)
		per_dout	=> per_dout,		-- Peripheral data output
		pmem_dout	=> pmem_dout,		-- Program Memory data output
		reset_n	=> reset_n,		-- Reset Pin (low active, asynchronous and non-glitchy)
		scan_enable	=> '0',		-- ASIC ONLY: Scan enable (active during scan shifting)
		scan_mode	=> '0',		-- ASIC ONLY: Scan mode
		wkup	=> '0'		-- ASIC ONLY: System Wake-up (asynchronous and non-glitchy)
	);

	--=============================================================================
	-- 5)  OPENMSP430 PERIPHERALS
	--=============================================================================

	-- Digital I/O
	---------------------------------
	gpio0: omsp_gpio
	generic map (
		P1_EN => 1,
		P2_EN => 1,
		P3_EN => 1,
		P4_EN => 0,
		P5_EN => 0,
		P6_EN => 0
	)
	port map (
		-- OUTPUTs
		irq_port1	=> irq_port1,		-- Port 1 interrupt
		irq_port2	=> irq_port2,		-- Port 2 interrupt
		p1_dout	=> p1_dout,		-- Port 1 data output
		p1_dout_en	=> p1_dout_en,		-- Port 1 data output enable
		p1_sel	=> p1_sel,		-- Port 1 function select
		p2_dout	=> p2_dout,		-- Port 2 data output
		p2_dout_en	=> p2_dout_en,		-- Port 2 data output enable
		p2_sel	=> p2_sel,		-- Port 2 function select
		p3_dout	=> p3_dout,		-- Port 3 data output
		p3_dout_en	=> p3_dout_en,		-- Port 3 data output enable
		p3_sel	=> p3_sel,		-- Port 3 function select
		p4_dout    => open,              -- Port 4 data output
		p4_dout_en => open,              -- Port 4 data output enable
		p4_sel     => open,              -- Port 4 function select
		p5_dout    => open,              -- Port 5 data output
		p5_dout_en => open,              -- Port 5 data output enable
		p5_sel     => open,              -- Port 5 function select
		p6_dout    => open,              -- Port 6 data output
		p6_dout_en => open,              -- Port 6 data output enable
		p6_sel     => open,              -- Port 6 function select
		per_dout	=> per_dout_dio,		-- Peripheral data output

		-- INPUTs
		mclk	=> mclk,		-- main system clock
		p1_din	=> p1_din,		-- Port 1 data input
		p2_din	=> p2_din,		-- Port 2 data input
		p3_din	=> p3_din,		-- Port 3 data input
		p4_din	=> (others => '0'),		-- Port 4 data input
		p5_din	=> (others => '0'),		-- Port 5 data input
		p6_din	=> (others => '0'),		-- Port 6 data input
		per_addr	=> per_addr,		-- Peripheral address
		per_din	=> per_din,		-- Peripheral data input
		per_en	=> per_en,		-- Peripheral enable (high active)
		per_we	=> per_we,		-- Peripheral write enable (high active)
		puc_rst	=> puc_rst	-- main system reset
	);

	-- Timer A
	------------------------------------------------
	timerA_0: omsp_timerA
	port map (
		-- OUTPUTs
		irq_ta0	=> irq_ta0,		-- Timer A interrupt: TACCR0
		irq_ta1	=> irq_ta1,		-- Timer A interrupt: TAIV, TACCR1, TACCR2
		per_dout	=> per_dout_tA,		-- Peripheral data output
		ta_out0	=> ta_out0,		-- Timer A output 0
		ta_out0_en	=> ta_out0_en,		-- Timer A output 0 enable
		ta_out1	=> ta_out1,		-- Timer A output 1
		ta_out1_en	=> ta_out1_en,		-- Timer A output 1 enable
		ta_out2	=> ta_out2,		-- Timer A output 2
		ta_out2_en	=> ta_out2_en,		-- Timer A output 2 enable

		-- INPUTs
		aclk_en	=> aclk_en,		-- ACLK enable (from CPU)
		dbg_freeze	=> dbg_freeze,		-- Freeze Timer A counter
		inclk	=> inclk,		-- inCLK external timer clock (SLOW)
		irq_ta0_acc	=> irq_acc(9),		-- interrupt request TACCR0 accepted
		mclk	=> mclk,		-- main system clock
		per_addr	=> per_addr,		-- Peripheral address
		per_din	=> per_din,		-- Peripheral data input
		per_en	=> per_en,		-- Peripheral enable (high active)
		per_we	=> per_we,		-- Peripheral write enable (high active)
		puc_rst	=> puc_rst,		-- main system reset
		smclk_en	=> smclk_en,		-- SMCLK enable (from CPU)
		ta_cci0a	=> ta_cci0a,		-- Timer A capture 0 input A
		ta_cci0b	=> ta_cci0b,		-- Timer A capture 0 input B
		ta_cci1a	=> ta_cci1a,		-- Timer A capture 1 input A
		ta_cci1b	=> '0',		-- Timer A capture 1 input B
		ta_cci2a	=> ta_cci2a,		-- Timer A capture 2 input A
		ta_cci2b	=> '0',		-- Timer A capture 2 input B
		taclk	=> taclk		-- TACLK external timer clock (SLOW)
	);

	uart0: omsp_uart
	generic map (BASE_ADDR => 16#0080#)
	port map
	(
		-- OUTPUTs
		irq_uart_rx  => irq_uart_rx,   -- UART receive interrupt
		irq_uart_tx  => irq_uart_tx,   -- UART transmit interrupt
		per_dout     => per_dout_uart, -- Peripheral data output
		uart_txd     => hw_uart_txd,   -- UART Data Transmit => TXD)
		-- INPUTs
		mclk         => mclk,          -- main system clock
		per_addr     => per_addr,      -- Peripheral address
		per_din      => per_din,       -- Peripheral data input
		per_en       => per_en,        -- Peripheral enable => high active)
		per_we       => per_we,        -- Peripheral write enable (high active)
		puc_rst      => puc_rst,       -- main system reset
		smclk_en     => smclk_en,      -- SMCLK enable (from CPU)
		uart_rxd     => hw_uart_rxd    -- UART Data Receive (RXD)
	);

	-- Combine peripheral data buses
	---------------------------------
	per_dout	<= per_dout_dio or per_dout_tA or per_dout_uart;

	-- Assign interrupts
	---------------------------------
	nmi	<= '0';
	irq_bus	<= ( '0'				-- Vector 13  (0xFFFA) higher priority
					& '0'				-- Vector 12  (0xFFF8)
					& '0'				-- Vector 11  (0xFFF6)
					& '0'				-- Vector 10  (0xFFF4) - Watchdog -
					& irq_ta0		-- Vector  9  (0xFFF2)
					& irq_ta1		-- Vector  8  (0xFFF0)
					& irq_uart_rx	-- Vector  7  (0xFFEE)
					& irq_uart_tx	-- Vector  6  (0xFFEC)
					& '0'				-- Vector  5  (0xFFEA)
					& '0'				-- Vector  4  (0xFFE8)
					& irq_port2		-- Vector  3  (0xFFE6)
					& irq_port1		-- Vector  2  (0xFFE4)
					& '0'				-- Vector  1  (0xFFE2)
					& '0' );			-- Vector  0  (0xFFE0) lowest priority

	-- GPIO Function selection
	---------------------------------
	-- P1.0/TACLK      I/O pin / Timer_A, clock signal TACLK input
	-- P1.1/TA0        I/O pin / Timer_A, capture: CCI0A input, compare: Out0 output
	-- P1.2/TA1        I/O pin / Timer_A, capture: CCI1A input, compare: Out1 output
	-- P1.3/TA2        I/O pin / Timer_A, capture: CCI2A input, compare: Out2 output
	-- P1.4/SMCLK      I/O pin / SMCLK signal output
	-- P1.5/TA0        I/O pin / Timer_A, compare: Out0 output
	-- P1.6/TA1        I/O pin / Timer_A, compare: Out1 output
	-- P1.7/TA2        I/O pin / Timer_A, compare: Out2 output
	io_mux_p1: io_mux
	port map (
		a_din	=> p1_din,
		a_dout	=> p1_dout,
		a_dout_en	=> p1_dout_en,

		b_din	=> p1_b_din, -- Verilog: (p1_io_mux_b_unconnected(7 downto 4) & ta_cci2a & ta_cci1a & ta_cci0a & taclk)
		b_dout	=> (ta_out2 & ta_out1 & ta_out0 & (smclk_en and mclk) & ta_out2 & ta_out1 & ta_out0 & '0'),
		b_dout_en	=> (ta_out2_en & ta_out1_en & ta_out0_en & '1' & ta_out2_en & ta_out1_en & ta_out0_en & '0'),

		io_din	=> p1_io_din,
		io_dout	=> p1_io_dout,
		io_dout_en	=> p1_io_dout_en,

		sel	=> p1_sel
	);
	ta_cci2a <= p1_b_din(3);
	ta_cci1a <= p1_b_din(2);
	ta_cci0a <= p1_b_din(1);
	taclk <= p1_b_din(0);

	-- P2.0/ACLK       I/O pin / ACLK output
	-- P2.1/inCLK      I/O pin / Timer_A, clock signal at inCLK
	-- P2.2/TA0        I/O pin / Timer_A, capture: CCI0B input
	-- P2.3/TA1        I/O pin / Timer_A, compare: Out1 output
	-- P2.4/TA2        I/O pin / Timer_A, compare: Out2 output
	io_mux_p2: io_mux
	port map (
		a_din	=> p2_din,
		a_dout	=> p2_dout,
		a_dout_en	=> p2_dout_en,

		b_din	=> p2_b_din, -- Verilog: (p2_io_mux_b_unconnected(7 downto 3) & ta_cci0b & inclk & p2_io_mux_b_unconnected(0))
		b_dout	=> ('0' & '0' & '0' & ta_out2 & ta_out1 & '0' & '0' & (aclk_en and mclk)),
		b_dout_en	=> ('0' & '0' & '0' & ta_out2_en & ta_out1_en & '0' & '0' & '1'),

		io_din	=> p2_io_din,
		io_dout	=> p2_io_dout,
		io_dout_en	=> p2_io_dout_en,

		sel	=> p2_sel
	);
	ta_cci0b <= p2_b_din(2);
	inclk <= p2_b_din(1);

	--=============================================================================
	-- 6)  RAM / ROM
	--=============================================================================

	DMEM_0 : dmem0 port map (
		address	 => dmem_addr(DMEM_MSB downto 0),
		clken	=> not(dmem_cen),
		clock	 => clk_sys,
		data	 => dmem_din,
		wren	 => not(dmem_wen(0) and dmem_wen(1)),
		byteena => not(dmem_wen),
		q	 => dmem_dout
	);
	
	PMEM_0 : pmem0 port map (
		address	 => pmem_addr(PMEM_MSB downto 0),
		clken	=> not(pmem_cen),
		clock	 => clk_sys,
		data	 => pmem_din,
		wren	 => not(pmem_wen(0) and pmem_wen(1)),
		byteena => not(pmem_wen),
		q	 => pmem_dout
	);


	--=============================================================================
	-- 7)  I/O CELLS
	--=============================================================================
	p3_din(7 downto 0) <= "0000" & SW(3 downto 0);
	LED(7 downto 0)	<= (p3_dout(7 downto 2) AND p3_dout_en(7 downto 2)) & dbg_uart_rxd & dbg_uart_txd;


	-- Serial Ports
	hw_uart_rxd	<= GPIO_0_IN(0);
	GPIO_0(0)	<= hw_uart_txd;
	
	dbg_uart_rxd	<= GPIO_0_IN(1);
	GPIO_0(1)	<= dbg_uart_txd;

end RTL;
