`timescale 1ns / 1ps

module uart_rx_led_top #(
    parameter int CLK_FREQ_HZ = 100_000_000,
    parameter int BAUD_RATE   = 115_200
) (
    input logic sys_clock,
    input logic reset,

    // UART from Master
    input logic rx,

    // SPI from Master
    input  logic spi_sclk,
    input  logic spi_mosi,
    output wire  spi_miso,
    input  logic spi_cs_n,

    // FND
    output logic [7:0] GPIOA,  // segment
    output logic [7:0] GPIOB,  // [3:0] anode/com

    // LED
    output logic [7:0] GPIOC,  // LED0~7 = latest received data
    output logic [7:0] GPIOD   // status LED
);

    // ============================================================
    // UART RX
    // ============================================================

    localparam int CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
    localparam int CNT_WIDTH = $clog2(CLKS_PER_BIT);

    typedef enum logic [1:0] {
        UART_IDLE,
        UART_START,
        UART_DATA,
        UART_STOP
    } uart_state_t;

    uart_state_t                 state;

    logic        [CNT_WIDTH-1:0] clk_cnt;
    logic        [          2:0] bit_idx;
    logic        [          7:0] uart_rx_shift;
    logic        [          7:0] uart_rx_data;
    logic                        uart_rx_done;

    logic                        rx_meta;
    logic                        rx_sync;

    always_ff @(posedge sys_clock) begin
        if (reset) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end

    always_ff @(posedge sys_clock) begin
        if (reset) begin
            state         <= UART_IDLE;
            clk_cnt       <= '0;
            bit_idx       <= 3'd0;
            uart_rx_shift <= 8'd0;
            uart_rx_data  <= 8'd0;
            uart_rx_done  <= 1'b0;
        end else begin
            uart_rx_done <= 1'b0;

            case (state)
                UART_IDLE: begin
                    clk_cnt <= '0;
                    bit_idx <= 3'd0;

                    if (rx_sync == 1'b0) begin
                        state <= UART_START;
                    end
                end

                UART_START: begin
                    if (clk_cnt == (CLKS_PER_BIT / 2) - 1) begin
                        clk_cnt <= '0;

                        if (rx_sync == 1'b0) begin
                            state <= UART_DATA;
                        end else begin
                            state <= UART_IDLE;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                UART_DATA: begin
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= '0;

                        uart_rx_shift[bit_idx] <= rx_sync;

                        if (bit_idx == 3'd7) begin
                            bit_idx <= 3'd0;
                            state   <= UART_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1'b1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                UART_STOP: begin
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt      <= '0;
                        uart_rx_data <= uart_rx_shift;
                        uart_rx_done <= 1'b1;
                        state        <= UART_IDLE;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                default: begin
                    state <= UART_IDLE;
                end
            endcase
        end
    end

    // ============================================================
    // SPI Slave
    // ============================================================

    logic [7:0] spi_rx_data;
    logic       spi_rx_done;
    logic       spi_tx_busy;

    spi_slave u_spi_slave (
        .clk  (sys_clock),
        .reset(reset),

        .sclk(spi_sclk),
        .mosi(spi_mosi),
        .miso(spi_miso),
        .cs_n(spi_cs_n),

        // 일단 고정 응답값.
        // Master 쪽 RX가 0xA5로 나오면 MISO 연결 확인 가능.
        .tx_data(8'hA5),

        .rx_data(spi_rx_data),
        .rx_done(spi_rx_done),
        .tx_busy(spi_tx_busy)
    );

    // ============================================================
    // Latest received data / status
    // ============================================================

    logic [7:0] display_data;
    logic       status_toggle;
    logic       uart_seen;
    logic       spi_seen;

    always_ff @(posedge sys_clock) begin
        if (reset) begin
            display_data  <= 8'h00;
            status_toggle <= 1'b0;
            uart_seen     <= 1'b0;
            spi_seen      <= 1'b0;
        end else begin
            if (uart_rx_done) begin
                display_data  <= uart_rx_shift;
                status_toggle <= ~status_toggle;
                uart_seen     <= 1'b1;
                spi_seen      <= 1'b0;
            end

            if (spi_rx_done) begin
                display_data  <= spi_rx_data;
                status_toggle <= ~status_toggle;
                uart_seen     <= 1'b0;
                spi_seen      <= 1'b1;
            end
        end
    end

    // LED output
    always_comb begin
        GPIOC    = display_data;

        GPIOD    = 8'h00;
        GPIOD[0] = uart_seen;  // UART로 받은 마지막 데이터
        GPIOD[1] = spi_seen;  // SPI로 받은 마지막 데이터
        GPIOD[2] = spi_tx_busy;  // SPI transaction active
        GPIOD[7] = status_toggle;  // receive event toggle
    end

    // ============================================================
    // FND display: latest received data, 2-digit HEX
    // ============================================================

    logic [15:0] refresh_cnt;
    logic [ 1:0] digit_sel;
    logic [ 3:0] fnd_nibble;
    logic [ 7:0] seg_data;

    always_ff @(posedge sys_clock) begin
        if (reset) begin
            refresh_cnt <= 16'd0;
        end else begin
            refresh_cnt <= refresh_cnt + 1'b1;
        end
    end

    assign digit_sel = refresh_cnt[15:14];

    always_comb begin
        fnd_nibble = 4'h0;
        GPIOB      = 8'hFF;

        case (digit_sel)
            2'd0: begin
                fnd_nibble = display_data[3:0];
                GPIOB[3:0] = 4'b1110;  // AN0 on
            end

            2'd1: begin
                fnd_nibble = display_data[7:4];
                GPIOB[3:0] = 4'b1101;  // AN1 on
            end

            default: begin
                fnd_nibble = 4'h0;
                GPIOB[3:0] = 4'b1111;
            end
        endcase
    end

    always_comb begin
        case (fnd_nibble)
            4'h0: seg_data = 8'hC0;
            4'h1: seg_data = 8'hF9;
            4'h2: seg_data = 8'hA4;
            4'h3: seg_data = 8'hB0;
            4'h4: seg_data = 8'h99;
            4'h5: seg_data = 8'h92;
            4'h6: seg_data = 8'h82;
            4'h7: seg_data = 8'hF8;
            4'h8: seg_data = 8'h80;
            4'h9: seg_data = 8'h90;
            4'hA: seg_data = 8'h88;
            4'hB: seg_data = 8'h83;
            4'hC: seg_data = 8'hC6;
            4'hD: seg_data = 8'hA1;
            4'hE: seg_data = 8'h86;
            4'hF: seg_data = 8'h8E;
            default: seg_data = 8'hFF;
        endcase

        GPIOA = seg_data;
    end

endmodule


// ============================================================
// SPI Slave - Mode 0
// CPOL=0, CPHA=0
// sample MOSI at rising edge, update MISO at falling edge
// ============================================================

module spi_slave (
    input logic clk,
    input logic reset,

    input  logic sclk,
    input  logic mosi,
    output wire  miso,
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

    assign miso = cs_active ? c_miso : 1'bz;

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
