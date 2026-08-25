`timescale 1ns / 1ps

// Testbench top: instantiates DUT, SPI response model, interfaces, and UVM.
package spi_axi_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi_lite_transaction.sv"
    `include "axi_lite_sequence.sv"
    `include "axi_lite_driver.sv"
    `include "axi_lite_monitor.sv"
    `include "spi_monitor.sv"
    `include "scoreboard.sv"
    `include "coverage.sv"
    `include "env.sv"
    `include "spi_axi_test.sv"
endpackage

module tb_top;
    import uvm_pkg::*;
    import spi_axi_pkg::*;

    logic aclk;

    initial begin
        aclk = 1'b0;
    end

    always #5 aclk = ~aclk;

    axi_lite_if axi_bus (.ACLK(aclk));
    spi_if      spi_bus (.clk(aclk));

    spi_v1_0 dut (
        .spi_sclk         (spi_bus.sclk),
        .spi_mosi         (spi_bus.mosi),
        .spi_miso         (spi_bus.miso),
        .spi_cs_n         (spi_bus.cs_n),
        .s00_axi_aclk     (aclk),
        .s00_axi_aresetn  (axi_bus.ARESETN),
        .s00_axi_awaddr   (axi_bus.AWADDR),
        .s00_axi_awprot   (axi_bus.AWPROT),
        .s00_axi_awvalid  (axi_bus.AWVALID),
        .s00_axi_awready  (axi_bus.AWREADY),
        .s00_axi_wdata    (axi_bus.WDATA),
        .s00_axi_wstrb    (axi_bus.WSTRB),
        .s00_axi_wvalid   (axi_bus.WVALID),
        .s00_axi_wready   (axi_bus.WREADY),
        .s00_axi_bresp    (axi_bus.BRESP),
        .s00_axi_bvalid   (axi_bus.BVALID),
        .s00_axi_bready   (axi_bus.BREADY),
        .s00_axi_araddr   (axi_bus.ARADDR),
        .s00_axi_arprot   (axi_bus.ARPROT),
        .s00_axi_arvalid  (axi_bus.ARVALID),
        .s00_axi_arready  (axi_bus.ARREADY),
        .s00_axi_rdata    (axi_bus.RDATA),
        .s00_axi_rresp    (axi_bus.RRESP),
        .s00_axi_rvalid   (axi_bus.RVALID),
        .s00_axi_rready   (axi_bus.RREADY)
    );

    spi_slave u_spi_slave_model (
        .clk     (aclk),
        .reset   (~axi_bus.ARESETN),
        .sclk    (spi_bus.sclk),
        .mosi    (spi_bus.mosi),
        .miso    (spi_bus.miso),
        .cs_n    (spi_bus.cs_n),
        .tx_data (spi_bus.slave_tx_data),
        .rx_data (spi_bus.slave_rx_data),
        .rx_done (spi_bus.slave_rx_done),
        .tx_busy (spi_bus.slave_tx_busy)
    );

    initial begin
        $fsdbDumpfile("./out/wave/tb_spi_axi.fsdb");
        $fsdbDumpvars(0, tb_top);
        $fsdbDumpMDA();
    end

    initial begin
        uvm_config_db#(virtual axi_lite_if)::set(null, "*", "axi_vif", axi_bus);
        uvm_config_db#(virtual spi_if)::set(null, "*", "spi_vif", spi_bus);
        run_test("spi_axi_test");
    end
endmodule
