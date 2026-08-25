+incdir+tb
+incdir+model

// Submitted SPI AXI peripheral RTL. spi_master is defined in spi_v1_0.v.
../../hardware/ip/spi/spi_v1_0_S00_AXI.v
../../hardware/ip/spi/spi_v1_0.v

// Testbench-only SPI slave response model
model/spi_slave.sv

// Interfaces
tb/axi_lite_if.sv
tb/spi_if.sv

// UVM classes are included by tb/tb_top.sv through spi_axi_pkg.
// tb/axi_lite_transaction.sv
// tb/axi_lite_sequence.sv
// tb/axi_lite_driver.sv
// tb/axi_lite_monitor.sv
// tb/spi_monitor.sv
// tb/scoreboard.sv
// tb/coverage.sv
// tb/env.sv
// tb/spi_axi_test.sv
tb/tb_top.sv
