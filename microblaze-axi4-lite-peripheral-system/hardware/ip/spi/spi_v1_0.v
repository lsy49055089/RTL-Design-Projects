
`timescale 1 ns / 1 ps

module spi_v1_0 #(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4
) (
    // Users to add ports here
    output wire spi_sclk,
    output wire spi_mosi,
    input  wire spi_miso,
    output wire spi_cs_n,
    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface S00_AXI
    input wire s00_axi_aclk,
    input wire s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire s00_axi_awvalid,
    output wire s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire s00_axi_wvalid,
    output wire s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire s00_axi_bvalid,
    input wire s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire s00_axi_arvalid,
    output wire s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire s00_axi_rvalid,
    input wire s00_axi_rready
);

    // Internal SPI control/status wires
    wire       spi_start_pulse;
    wire [7:0] spi_tx_data;
    wire [7:0] spi_clk_div;

    wire       spi_busy;
    wire       spi_done;
    wire [7:0] spi_rx_data;
    // Instantiation of Axi Bus Interface S00_AXI
    spi_v1_0_S00_AXI #(
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) spi_v1_0_S00_AXI_inst (
        .start_pulse(spi_start_pulse),
        .tx_data    (spi_tx_data),
        .clk_div    (spi_clk_div),

        .spi_busy   (spi_busy),
        .spi_done   (spi_done),
        .spi_rx_data(spi_rx_data),

        .S_AXI_ACLK(s00_axi_aclk),
        .S_AXI_ARESETN(s00_axi_aresetn),
        .S_AXI_AWADDR(s00_axi_awaddr),
        .S_AXI_AWPROT(s00_axi_awprot),
        .S_AXI_AWVALID(s00_axi_awvalid),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WDATA(s00_axi_wdata),
        .S_AXI_WSTRB(s00_axi_wstrb),
        .S_AXI_WVALID(s00_axi_wvalid),
        .S_AXI_WREADY(s00_axi_wready),
        .S_AXI_BRESP(s00_axi_bresp),
        .S_AXI_BVALID(s00_axi_bvalid),
        .S_AXI_BREADY(s00_axi_bready),
        .S_AXI_ARADDR(s00_axi_araddr),
        .S_AXI_ARPROT(s00_axi_arprot),
        .S_AXI_ARVALID(s00_axi_arvalid),
        .S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_RDATA(s00_axi_rdata),
        .S_AXI_RRESP(s00_axi_rresp),
        .S_AXI_RVALID(s00_axi_rvalid),
        .S_AXI_RREADY(s00_axi_rready)
    );

    // Add user logic here
    spi_master u_spi_master (
        .clk  (s00_axi_aclk),
        .reset(~s00_axi_aresetn),

        .start  (spi_start_pulse),
        .clk_div(spi_clk_div),

        .tx_data(spi_tx_data),
        .tx_busy(spi_busy),
        .rx_data(spi_rx_data),
        .rx_done(spi_done),

        .sclk(spi_sclk),
        .mosi(spi_mosi),
        .miso(spi_miso),
        .cs_n(spi_cs_n)
    );
    // User logic ends

endmodule



module spi_master (
    input wire clk,
    input wire reset,

    input wire       start,
    input wire [7:0] clk_div,

    input  wire [7:0] tx_data,
    output wire       tx_busy,
    output wire [7:0] rx_data,
    output wire       rx_done,

    output wire sclk,
    output wire mosi,
    input  wire miso,
    output wire cs_n
);

    localparam [1:0] IDLE = 2'b00;
    localparam [1:0] LOAD = 2'b01;
    localparam [1:0] DATA = 2'b10;
    localparam [1:0] STOP = 2'b11;

    reg [1:0] c_state;
    reg [1:0] n_state;

    reg [7:0] c_div_cnt;
    reg [7:0] n_div_cnt;

    reg [7:0] c_clk_div;
    reg [7:0] n_clk_div;

    reg c_sclk;
    reg n_sclk;

    reg c_mosi;
    reg n_mosi;

    reg c_cs_n;
    reg n_cs_n;

    reg c_tx_busy;
    reg n_tx_busy;

    reg c_rx_done;
    reg n_rx_done;

    reg [7:0] c_tx_shift_reg;
    reg [7:0] n_tx_shift_reg;

    reg [7:0] c_rx_shift_reg;
    reg [7:0] n_rx_shift_reg;

    reg [7:0] c_rx_data;
    reg [7:0] n_rx_data;

    reg [2:0] c_bit_cnt;
    reg [2:0] n_bit_cnt;

    reg half_tick;

    assign sclk    = c_sclk;
    assign mosi    = c_mosi;
    assign cs_n    = c_cs_n;
    assign tx_busy = c_tx_busy;
    assign rx_done = c_rx_done;
    assign rx_data = c_rx_data;

    always @(*) begin
        n_state        = c_state;

        n_div_cnt      = c_div_cnt;
        n_clk_div      = c_clk_div;

        n_sclk         = c_sclk;
        n_mosi         = c_mosi;
        n_cs_n         = c_cs_n;
        n_tx_busy      = c_tx_busy;
        n_rx_done      = 1'b0;

        n_tx_shift_reg = c_tx_shift_reg;
        n_rx_shift_reg = c_rx_shift_reg;
        n_rx_data      = c_rx_data;
        n_bit_cnt      = c_bit_cnt;

        half_tick      = 1'b0;

        // half tick generation
        if (c_state == DATA) begin
            if (c_div_cnt >= c_clk_div) begin
                n_div_cnt = 8'd0;
                half_tick = 1'b1;
            end else begin
                n_div_cnt = c_div_cnt + 1'b1;
            end
        end else begin
            n_div_cnt = 8'd0;
        end

        case (c_state)
            IDLE: begin
                n_sclk    = 1'b0;   // Mode 0: CPOL=0
                n_mosi    = 1'b0;
                n_cs_n    = 1'b1;
                n_tx_busy = 1'b0;
                n_bit_cnt = 3'd0;

                if (start) begin
                    n_state = LOAD;
                end
            end

            LOAD: begin
                n_cs_n         = 1'b0;
                n_tx_busy      = 1'b1;
                n_clk_div      = clk_div;

                // first bit preload for Mode 0
                n_mosi         = tx_data[7];
                n_tx_shift_reg = {tx_data[6:0], 1'b0};

                n_rx_shift_reg = 8'd0;
                n_bit_cnt      = 3'd0;
                n_state        = DATA;
            end

            DATA: begin
                if (half_tick) begin
                    n_sclk = ~c_sclk;

                    if (c_sclk == 1'b0) begin
                        // rising edge: sample MISO
                        n_rx_shift_reg = {c_rx_shift_reg[6:0], miso};

                        if (c_bit_cnt == 3'd7) begin
                            n_rx_data = {c_rx_shift_reg[6:0], miso};
                            n_state   = STOP;
                        end else begin
                            n_bit_cnt = c_bit_cnt + 1'b1;
                        end
                    end else begin
                        // falling edge: update MOSI
                        n_mosi         = c_tx_shift_reg[7];
                        n_tx_shift_reg = {c_tx_shift_reg[6:0], 1'b0};
                    end
                end
            end

            STOP: begin
                n_sclk    = 1'b0;
                n_cs_n    = 1'b1;
                n_tx_busy = 1'b0;
                n_rx_done = 1'b1;
                n_mosi    = 1'b0;
                n_state   = IDLE;
            end

            default: begin
                n_state = IDLE;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            c_state        <= IDLE;

            c_div_cnt      <= 8'd0;
            c_clk_div      <= 8'd0;

            c_sclk         <= 1'b0;
            c_mosi         <= 1'b0;
            c_cs_n         <= 1'b1;
            c_tx_busy      <= 1'b0;
            c_rx_done      <= 1'b0;

            c_tx_shift_reg <= 8'd0;
            c_rx_shift_reg <= 8'd0;
            c_rx_data      <= 8'd0;
            c_bit_cnt      <= 3'd0;
        end else begin
            c_state        <= n_state;

            c_div_cnt      <= n_div_cnt;
            c_clk_div      <= n_clk_div;

            c_sclk         <= n_sclk;
            c_mosi         <= n_mosi;
            c_cs_n         <= n_cs_n;
            c_tx_busy      <= n_tx_busy;
            c_rx_done      <= n_rx_done;

            c_tx_shift_reg <= n_tx_shift_reg;
            c_rx_shift_reg <= n_rx_shift_reg;
            c_rx_data      <= n_rx_data;
            c_bit_cnt      <= n_bit_cnt;
        end
    end

endmodule
