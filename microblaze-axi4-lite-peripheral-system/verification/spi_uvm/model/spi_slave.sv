`timescale 1ns / 1ps

// Testbench SPI slave response model; this is not part of the DUT.
module spi_slave (
    input logic clk,
    input logic reset,

    input  logic sclk,
    input  logic mosi,
    output logic miso,
    input  logic cs_n,

    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       rx_done,
    output logic       tx_busy
);

    logic [2:0] c_sclk_sync, n_sclk_sync;
    logic [2:0] c_cs_n_sync, n_cs_n_sync;
    logic [1:0] c_mosi_sync, n_mosi_sync;

    logic sclk_rise;
    logic sclk_fall;
    logic cs_fall;
    logic cs_rise;
    logic cs_active;
    logic mosi_sampled;

    assign sclk_rise    = (c_sclk_sync[2:1] == 2'b01);
    assign sclk_fall    = (c_sclk_sync[2:1] == 2'b10);
    assign cs_fall      = (c_cs_n_sync[2:1] == 2'b10);
    assign cs_rise      = (c_cs_n_sync[2:1] == 2'b01);
    assign cs_active    = ~c_cs_n_sync[1];
    assign mosi_sampled = c_mosi_sync[1];

    logic [7:0] c_rx_shift_reg, n_rx_shift_reg;
    logic [7:0] c_tx_shift_reg, n_tx_shift_reg;
    logic [7:0] c_rx_data, n_rx_data;
    logic [2:0] c_bit_cnt, n_bit_cnt;
    logic c_rx_done, n_rx_done;
    logic c_tx_busy, n_tx_busy;
    logic c_miso, n_miso;

    assign rx_data = c_rx_data;
    assign rx_done = c_rx_done;
    assign tx_busy = c_tx_busy;
    assign miso    = cs_active ? c_miso : 1'b0;

    always_comb begin
        n_sclk_sync    = {c_sclk_sync[1:0], sclk};
        n_cs_n_sync    = {c_cs_n_sync[1:0], cs_n};
        n_mosi_sync    = {c_mosi_sync[0], mosi};

        n_rx_shift_reg = c_rx_shift_reg;
        n_tx_shift_reg = c_tx_shift_reg;
        n_rx_data      = c_rx_data;
        n_bit_cnt      = c_bit_cnt;
        n_rx_done      = 1'b0;
        n_tx_busy      = c_tx_busy;
        n_miso         = c_miso;

        if (cs_fall) begin
            n_tx_busy      = 1'b1;
            n_tx_shift_reg = tx_data;
            n_miso         = tx_data[7];
            n_rx_shift_reg = 8'd0;
            n_bit_cnt      = 3'd0;
            n_rx_done      = 1'b0;
        end

        if (cs_active) begin
            if (sclk_rise) begin
                n_rx_shift_reg = {c_rx_shift_reg[6:0], mosi_sampled};

                if (c_bit_cnt == 3'd7) begin
                    n_rx_data = {c_rx_shift_reg[6:0], mosi_sampled};
                    n_rx_done = 1'b1;
                    n_bit_cnt = 3'd0;
                end else begin
                    n_bit_cnt = c_bit_cnt + 1'b1;
                end
            end

            if (sclk_fall) begin
                n_miso         = c_tx_shift_reg[6];
                n_tx_shift_reg = {c_tx_shift_reg[6:0], 1'b0};
            end
        end

        if (cs_rise) begin
            n_tx_busy      = 1'b0;
            n_miso         = 1'b0;
            n_rx_shift_reg = 8'd0;
            n_tx_shift_reg = 8'd0;
            n_bit_cnt      = 3'd0;
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            c_sclk_sync    <= 3'b000;
            c_cs_n_sync    <= 3'b111;
            c_mosi_sync    <= 2'b00;
            c_rx_shift_reg <= 8'd0;
            c_tx_shift_reg <= 8'd0;
            c_rx_data      <= 8'd0;
            c_bit_cnt      <= 3'd0;
            c_rx_done      <= 1'b0;
            c_tx_busy      <= 1'b0;
            c_miso         <= 1'b0;
        end else begin
            c_sclk_sync    <= n_sclk_sync;
            c_cs_n_sync    <= n_cs_n_sync;
            c_mosi_sync    <= n_mosi_sync;
            c_rx_shift_reg <= n_rx_shift_reg;
            c_tx_shift_reg <= n_tx_shift_reg;
            c_rx_data      <= n_rx_data;
            c_bit_cnt      <= n_bit_cnt;
            c_rx_done      <= n_rx_done;
            c_tx_busy      <= n_tx_busy;
            c_miso         <= n_miso;
        end
    end

endmodule
