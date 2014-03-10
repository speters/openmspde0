//=============================================================================
// Configuration
// Taken from external/opencores.org_-_openmsp430/core/rtl/verilog/openMSP430_defines.v
// Keep in sync with config.vhd!
//=============================================================================
`define OMSP_NO_INCLUDE
`include "openMSP430_defines.v"

//=============================================================================
// FPGA Specific modules
//=============================================================================

`include "external/opencores.org_-_openmsp430/fpga/altera_de1_board/rtl/verilog/io_mux.v"
`include "external/opencores.org_-_openmsp430/fpga/xilinx_diligent_s3board/rtl/verilog/omsp_uart.v"


//=============================================================================
// openMSP430
//=============================================================================

`include "external/opencores.org_-_openmsp430/core/rtl/verilog/openMSP430.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_frontend.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_execution_unit.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_register_file.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_alu.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_sfr.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_mem_backbone.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_clock_module.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_dbg.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_dbg_hwbrk.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_dbg_uart.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_dbg_i2c.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_watchdog.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_multiplier.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_sync_reset.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_sync_cell.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_scan_mux.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_and_gate.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_wakeup_cell.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_clock_gate.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/omsp_clock_mux.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/periph/omsp_gpio.v"
`include "external/opencores.org_-_openmsp430/core/rtl/verilog/periph/omsp_timerA.v"

