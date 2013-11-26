-- openMSP430 VHDL config
-- This should match the settings supplied in openMSP430_defines.v !!!

package config is
	-- constant PMEM_MSB : integer := 9;	-- 2kB	(openMSP430_defines.v standard)
	-- constant DMEM_MSB : integer := 5;	-- 128B  (openMSP430_defines.v standard)
	constant PMEM_MSB : integer := 10;	-- 4kB
	constant DMEM_MSB : integer := 8;	-- 1KB
	constant PER_MSB 	: integer := 7;	-- 512B 	(MSP430 standard)

	constant DCO_FREQ : integer := 50_000_000;	-- DCO frequency (DE0nano: 50Mhz)
end;