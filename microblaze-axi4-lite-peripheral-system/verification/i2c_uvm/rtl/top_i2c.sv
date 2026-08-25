`timescale 1ns / 1ps

module top_i2c(
    input  logic       clk,
    input  logic       reset,

    input  logic       cmd_start,
    input  logic       cmd_write,
    input  logic       cmd_read,
    input  logic       cmd_stop,

    input  logic [7:0] master_tx_data,
    output logic [7:0] master_rx_data,
    input  logic       ack_in,
    output logic       ack_out,

    output logic       master_busy,
    output logic       master_done,

    input  logic [6:0] slave_addr,
    input  logic [7:0] slave_tx_data,
    output logic [7:0] slave_rx_data,

    output logic       slave_addr_match,
    output logic       slave_rw_mode,
    output logic       slave_master_ack,
    output logic       slave_busy,
    output logic       slave_done
);

    logic scl;
    tri   sda;

    pullup(sda);

    I2C_master_top u_master(
        .clk       (clk),
        .reset     (reset),
        .cmd_start (cmd_start),
        .cmd_write (cmd_write),
        .cmd_read  (cmd_read),
        .cmd_stop  (cmd_stop),

        .tx_data   (master_tx_data),
        .rx_data   (master_rx_data),
        .ack_in    (ack_in),
        .ack_out   (ack_out),
        .busy      (master_busy),
        .done      (master_done),

        .scl       (scl),
        .sda       (sda)
    );

    I2C_slave_top u_slave(
        .clk        (clk),
        .reset      (reset),

        .slave_addr (slave_addr),
        .tx_data    (slave_tx_data),
        .rx_data    (slave_rx_data),

        .addr_match (slave_addr_match),
        .rw_mode    (slave_rw_mode),
        .master_ack (slave_master_ack),
        .busy       (slave_busy),
        .done       (slave_done),

        .scl        (scl),
        .sda        (sda)
    );

endmodule