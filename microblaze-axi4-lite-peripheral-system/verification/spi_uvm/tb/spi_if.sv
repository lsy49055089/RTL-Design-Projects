`timescale 1ns / 1ps

// SPI bus interface plus knobs/status for the testbench slave model.
interface spi_if (
    input logic clk
);

    logic sclk;
    logic mosi;
    logic miso;
    logic cs_n;

    logic [7:0] slave_tx_data;
    logic [7:0] slave_rx_data;
    logic       slave_rx_done;
    logic       slave_tx_busy;

    initial begin
        slave_tx_data = 8'h00;
    end

endinterface
