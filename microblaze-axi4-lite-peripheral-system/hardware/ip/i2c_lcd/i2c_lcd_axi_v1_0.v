
`timescale 1 ns / 1 ps

module i2c_lcd_axi_v1_0 #(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4
) (
    // Users to add ports here
    output wire lcd_scl,
    inout  wire lcd_sda,
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

    wire        start_pulse;
    wire        clr_status_pulse;
    wire [31:0] data_reg;

    wire        core_busy;
    wire        core_done;
    wire        core_ack_error;

    // I2C master control signals
    wire        i2c_cmd_start;
    wire        i2c_cmd_write;
    wire        i2c_cmd_stop;
    wire [ 7:0] i2c_tx_data;

    wire        i2c_ack_out;
    wire        i2c_busy;
    wire        i2c_done;

    wire        sda_o;
    wire        sda_i;
    assign sda_i   = lcd_sda;
    assign lcd_sda = (sda_o == 1'b0) ? 1'b0 : 1'bz;
    // Instantiation of Axi Bus Interface S00_AXI
    i2c_lcd_axi_v1_0_S00_AXI #(
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) i2c_lcd_axi_v1_0_S00_AXI_inst (
        .start_pulse     (start_pulse),
        .clr_status_pulse(clr_status_pulse),
        .data_reg        (data_reg),

        .core_busy     (core_busy),
        .core_done     (core_done),
        .core_ack_error(core_ack_error),
        .S_AXI_ACLK    (s00_axi_aclk),
        .S_AXI_ARESETN (s00_axi_aresetn),
        .S_AXI_AWADDR  (s00_axi_awaddr),
        .S_AXI_AWPROT  (s00_axi_awprot),
        .S_AXI_AWVALID (s00_axi_awvalid),
        .S_AXI_AWREADY (s00_axi_awready),
        .S_AXI_WDATA   (s00_axi_wdata),
        .S_AXI_WSTRB   (s00_axi_wstrb),
        .S_AXI_WVALID  (s00_axi_wvalid),
        .S_AXI_WREADY  (s00_axi_wready),
        .S_AXI_BRESP   (s00_axi_bresp),
        .S_AXI_BVALID  (s00_axi_bvalid),
        .S_AXI_BREADY  (s00_axi_bready),
        .S_AXI_ARADDR  (s00_axi_araddr),
        .S_AXI_ARPROT  (s00_axi_arprot),
        .S_AXI_ARVALID (s00_axi_arvalid),
        .S_AXI_ARREADY (s00_axi_arready),
        .S_AXI_RDATA   (s00_axi_rdata),
        .S_AXI_RRESP   (s00_axi_rresp),
        .S_AXI_RVALID  (s00_axi_rvalid),
        .S_AXI_RREADY  (s00_axi_rready)
    );

    // Add user logic here
    i2c_lcd_core #(
        .LCD_ADDR(7'h27)
    ) u_i2c_lcd_core (
        .clk(s00_axi_aclk),
        .rst(~s00_axi_aresetn),

        .start     (start_pulse),
        .clr_status(clr_status_pulse),
        .data_i    (data_reg),

        .busy     (core_busy),
        .done     (core_done),
        .ack_error(core_ack_error),

        .i2c_cmd_start(i2c_cmd_start),
        .i2c_cmd_write(i2c_cmd_write),
        .i2c_cmd_stop (i2c_cmd_stop),
        .i2c_tx_data  (i2c_tx_data),

        .i2c_ack_out(i2c_ack_out),
        .i2c_busy   (i2c_busy),
        .i2c_done   (i2c_done)
    );

    i2c_master u_i2c_master (
        .clk(s00_axi_aclk),
        .rst(~s00_axi_aresetn),

        .cmd_start(i2c_cmd_start),
        .cmd_write(i2c_cmd_write),
        .cmd_read (1'b0),
        .cmd_stop (i2c_cmd_stop),

        .tx_data(i2c_tx_data),
        .rx_data(),
        .ack_in (1'b1),
        .ack_out(i2c_ack_out),
        .busy   (i2c_busy),
        .done   (i2c_done),

        .scl  (lcd_scl),
        .sda_o(sda_o),
        .sda_i(sda_i)
    );
    // User logic ends

endmodule



module i2c_lcd_core #(
    parameter [6:0] LCD_ADDR    = 7'h27,
    parameter integer CLK_FREQ_HZ = 100_000_000
) (
    input wire clk,
    input wire rst,

    input wire        start,
    input wire        clr_status,
    input wire [31:0] data_i,

    output reg busy,
    output reg done,
    output reg ack_error,

    output reg       i2c_cmd_start,
    output reg       i2c_cmd_write,
    output reg       i2c_cmd_stop,
    output reg [7:0] i2c_tx_data,

    input wire i2c_ack_out,
    input wire i2c_busy,
    input wire i2c_done
);

    // ------------------------------------------------------------
    // LCD / PCF8574 mapping
    // PCF8574 byte = {D7,D6,D5,D4,BL,EN,RW,RS}
    // BL = 1, RW = 0
    // ------------------------------------------------------------

    localparam [3:0] IDLE = 4'd0;
    localparam [3:0] POWER_WAIT = 4'd1;
    localparam [3:0] LOAD_BYTE = 4'd2;
    localparam [3:0] LOAD_PCF = 4'd3;
    localparam [3:0] SEND_START = 4'd4;
    localparam [3:0] WAIT_START = 4'd5;
    localparam [3:0] SEND_ADDR = 4'd6;
    localparam [3:0] WAIT_ADDR = 4'd7;
    localparam [3:0] SEND_DATA = 4'd8;
    localparam [3:0] WAIT_DATA = 4'd9;
    localparam [3:0] SEND_STOP = 4'd10;
    localparam [3:0] WAIT_STOP = 4'd11;
    localparam [3:0] NEXT_PCF = 4'd12;
    localparam [3:0] DELAY = 4'd13;
    localparam [3:0] FINISH = 4'd14;

    localparam integer POWER_DELAY_CYCLES = CLK_FREQ_HZ / 5;  // 200ms
    localparam integer SHORT_DELAY_CYCLES = CLK_FREQ_HZ / 500;  // 2ms
    localparam integer CLEAR_DELAY_CYCLES = CLK_FREQ_HZ / 100;  // 10ms

    // sequence 개수
    // 0x33, 0x32, 0x28, 0x0C, 0x01, 0x06, 0x80, 'H','E','L','L','O'
    localparam [5:0] FULL_SEQ_LEN = 6'd43;  // init + line1 + line2
    localparam [5:0] UPDATE_SEQ_LEN = 6'd37;  // clear + line1 + line2

    reg  [ 3:0] state;
    reg  [31:0] delay_cnt;
    reg  [31:0] delay_target;

    reg  [ 5:0] seq_idx;
    reg         lcd_initialized;
    reg         seq_full_init;
    reg  [ 7:0] lcd_byte;
    reg         lcd_rs;
    reg  [ 1:0] pcf_phase;
    reg  [ 7:0] pcf_byte;

    wire [ 7:0] disp_value;
    wire [ 1:0] disp_mode;

    assign disp_value = data_i[7:0];
    assign disp_mode  = data_i[9:8];

    // ------------------------------------------------------------
    // LCD 출력 sequence
    // return {RS, DATA}
    // RS=0: command
    // RS=1: character data
    // ------------------------------------------------------------
    function [7:0] hex_to_ascii;
        input [3:0] hex;
        begin
            case (hex)
                4'h0: hex_to_ascii = "0";
                4'h1: hex_to_ascii = "1";
                4'h2: hex_to_ascii = "2";
                4'h3: hex_to_ascii = "3";
                4'h4: hex_to_ascii = "4";
                4'h5: hex_to_ascii = "5";
                4'h6: hex_to_ascii = "6";
                4'h7: hex_to_ascii = "7";
                4'h8: hex_to_ascii = "8";
                4'h9: hex_to_ascii = "9";
                4'hA: hex_to_ascii = "A";
                4'hB: hex_to_ascii = "B";
                4'hC: hex_to_ascii = "C";
                4'hD: hex_to_ascii = "D";
                4'hE: hex_to_ascii = "E";
                4'hF: hex_to_ascii = "F";
                default: hex_to_ascii = " ";
            endcase
        end
    endfunction

    function [7:0] line1_char;
        input [4:0] pos;
        begin
            case (pos)
                5'd0: begin
                    case (disp_mode)
                        2'd0: line1_char = "S";
                        2'd1: line1_char = "U";
                        2'd2: line1_char = "S";
                        2'd3: line1_char = "T";
                    endcase
                end
                5'd1: begin
                    case (disp_mode)
                        2'd0: line1_char = "W";
                        2'd1: line1_char = "A";
                        2'd2: line1_char = "P";
                        2'd3: line1_char = "I";
                    endcase
                end
                5'd2: begin
                    case (disp_mode)
                        2'd0: line1_char = " ";
                        2'd1: line1_char = "R";
                        2'd2: line1_char = "I";
                        2'd3: line1_char = "M";
                    endcase
                end
                5'd3: begin
                    case (disp_mode)
                        2'd0: line1_char = "I";
                        2'd1: line1_char = "T";
                        2'd2: line1_char = " ";
                        2'd3: line1_char = "E";
                    endcase
                end
                5'd4: begin
                    case (disp_mode)
                        2'd0: line1_char = "N";
                        2'd1: line1_char = " ";
                        2'd2: line1_char = "S";
                        2'd3: line1_char = "R";
                    endcase
                end
                5'd5: begin
                    case (disp_mode)
                        2'd0: line1_char = "P";
                        2'd1: line1_char = "S";
                        2'd2: line1_char = "E";
                        2'd3: line1_char = " ";
                    endcase
                end
                5'd6: begin
                    case (disp_mode)
                        2'd0: line1_char = "U";
                        2'd1: line1_char = "E";
                        2'd2: line1_char = "N";
                        2'd3: line1_char = " ";
                    endcase
                end
                5'd7: begin
                    case (disp_mode)
                        2'd0: line1_char = "T";
                        2'd1: line1_char = "N";
                        2'd2: line1_char = "D";
                        2'd3: line1_char = " ";
                    endcase
                end
                5'd8: begin
                    case (disp_mode)
                        2'd0: line1_char = " ";
                        2'd1: line1_char = "D";
                        2'd2: line1_char = " ";
                        2'd3: line1_char = " ";
                    endcase
                end
                default: line1_char = " ";
            endcase
        end
    endfunction

    function [7:0] line2_char;
        input [4:0] pos;
        begin
            case (pos)
                5'd0: begin
                    if (disp_mode == 2'd3) line2_char = "C";
                    else line2_char = "D";
                end

                5'd1: begin
                    if (disp_mode == 2'd3) line2_char = "N";
                    else line2_char = "A";
                end

                5'd2: line2_char = "T";

                5'd3: begin
                    if (disp_mode == 2'd3) line2_char = " ";
                    else line2_char = "A";
                end

                5'd4: line2_char = " ";
                5'd5: line2_char = "0";
                5'd6: line2_char = "x";
                5'd7: line2_char = hex_to_ascii(disp_value[7:4]);
                5'd8: line2_char = hex_to_ascii(disp_value[3:0]);

                default: line2_char = " ";
            endcase
        end
    endfunction

    function [8:0] get_lcd_item;
        input [5:0] idx;
        begin
            if (seq_full_init) begin
                case (idx)
                    6'd0: get_lcd_item = {1'b0, 8'h30};
                    6'd1: get_lcd_item = {1'b0, 8'h30};
                    6'd2: get_lcd_item = {1'b0, 8'h30};
                    6'd3: get_lcd_item = {1'b0, 8'h20};
                    6'd4: get_lcd_item = {1'b0, 8'h28};
                    6'd5: get_lcd_item = {1'b0, 8'h08};
                    6'd6: get_lcd_item = {1'b0, 8'h01};
                    6'd7: get_lcd_item = {1'b0, 8'h06};
                    6'd8: get_lcd_item = {1'b0, 8'h0C};

                    6'd9: get_lcd_item = {1'b0, 8'h80};

                    6'd10: get_lcd_item = {1'b1, line1_char(5'd0)};
                    6'd11: get_lcd_item = {1'b1, line1_char(5'd1)};
                    6'd12: get_lcd_item = {1'b1, line1_char(5'd2)};
                    6'd13: get_lcd_item = {1'b1, line1_char(5'd3)};
                    6'd14: get_lcd_item = {1'b1, line1_char(5'd4)};
                    6'd15: get_lcd_item = {1'b1, line1_char(5'd5)};
                    6'd16: get_lcd_item = {1'b1, line1_char(5'd6)};
                    6'd17: get_lcd_item = {1'b1, line1_char(5'd7)};
                    6'd18: get_lcd_item = {1'b1, line1_char(5'd8)};
                    6'd19: get_lcd_item = {1'b1, line1_char(5'd9)};
                    6'd20: get_lcd_item = {1'b1, line1_char(5'd10)};
                    6'd21: get_lcd_item = {1'b1, line1_char(5'd11)};
                    6'd22: get_lcd_item = {1'b1, line1_char(5'd12)};
                    6'd23: get_lcd_item = {1'b1, line1_char(5'd13)};
                    6'd24: get_lcd_item = {1'b1, line1_char(5'd14)};
                    6'd25: get_lcd_item = {1'b1, line1_char(5'd15)};

                    6'd26: get_lcd_item = {1'b0, 8'hC0};

                    6'd27: get_lcd_item = {1'b1, line2_char(5'd0)};
                    6'd28: get_lcd_item = {1'b1, line2_char(5'd1)};
                    6'd29: get_lcd_item = {1'b1, line2_char(5'd2)};
                    6'd30: get_lcd_item = {1'b1, line2_char(5'd3)};
                    6'd31: get_lcd_item = {1'b1, line2_char(5'd4)};
                    6'd32: get_lcd_item = {1'b1, line2_char(5'd5)};
                    6'd33: get_lcd_item = {1'b1, line2_char(5'd6)};
                    6'd34: get_lcd_item = {1'b1, line2_char(5'd7)};
                    6'd35: get_lcd_item = {1'b1, line2_char(5'd8)};
                    6'd36: get_lcd_item = {1'b1, line2_char(5'd9)};
                    6'd37: get_lcd_item = {1'b1, line2_char(5'd10)};
                    6'd38: get_lcd_item = {1'b1, line2_char(5'd11)};
                    6'd39: get_lcd_item = {1'b1, line2_char(5'd12)};
                    6'd40: get_lcd_item = {1'b1, line2_char(5'd13)};
                    6'd41: get_lcd_item = {1'b1, line2_char(5'd14)};
                    6'd42: get_lcd_item = {1'b1, line2_char(5'd15)};

                    default: get_lcd_item = {1'b1, " "};
                endcase
            end else begin
                case (idx)
                    6'd0: get_lcd_item = {1'b0, 8'h01};  // clear
                    6'd1: get_lcd_item = {1'b0, 8'h06};  // entry mode
                    6'd2: get_lcd_item = {1'b0, 8'h0C};  // display on
                    6'd3: get_lcd_item = {1'b0, 8'h80};  // line1

                    6'd4:  get_lcd_item = {1'b1, line1_char(5'd0)};
                    6'd5:  get_lcd_item = {1'b1, line1_char(5'd1)};
                    6'd6:  get_lcd_item = {1'b1, line1_char(5'd2)};
                    6'd7:  get_lcd_item = {1'b1, line1_char(5'd3)};
                    6'd8:  get_lcd_item = {1'b1, line1_char(5'd4)};
                    6'd9:  get_lcd_item = {1'b1, line1_char(5'd5)};
                    6'd10: get_lcd_item = {1'b1, line1_char(5'd6)};
                    6'd11: get_lcd_item = {1'b1, line1_char(5'd7)};
                    6'd12: get_lcd_item = {1'b1, line1_char(5'd8)};
                    6'd13: get_lcd_item = {1'b1, line1_char(5'd9)};
                    6'd14: get_lcd_item = {1'b1, line1_char(5'd10)};
                    6'd15: get_lcd_item = {1'b1, line1_char(5'd11)};
                    6'd16: get_lcd_item = {1'b1, line1_char(5'd12)};
                    6'd17: get_lcd_item = {1'b1, line1_char(5'd13)};
                    6'd18: get_lcd_item = {1'b1, line1_char(5'd14)};
                    6'd19: get_lcd_item = {1'b1, line1_char(5'd15)};

                    6'd20: get_lcd_item = {1'b0, 8'hC0};  // line2

                    6'd21: get_lcd_item = {1'b1, line2_char(5'd0)};
                    6'd22: get_lcd_item = {1'b1, line2_char(5'd1)};
                    6'd23: get_lcd_item = {1'b1, line2_char(5'd2)};
                    6'd24: get_lcd_item = {1'b1, line2_char(5'd3)};
                    6'd25: get_lcd_item = {1'b1, line2_char(5'd4)};
                    6'd26: get_lcd_item = {1'b1, line2_char(5'd5)};
                    6'd27: get_lcd_item = {1'b1, line2_char(5'd6)};
                    6'd28: get_lcd_item = {1'b1, line2_char(5'd7)};
                    6'd29: get_lcd_item = {1'b1, line2_char(5'd8)};
                    6'd30: get_lcd_item = {1'b1, line2_char(5'd9)};
                    6'd31: get_lcd_item = {1'b1, line2_char(5'd10)};
                    6'd32: get_lcd_item = {1'b1, line2_char(5'd11)};
                    6'd33: get_lcd_item = {1'b1, line2_char(5'd12)};
                    6'd34: get_lcd_item = {1'b1, line2_char(5'd13)};
                    6'd35: get_lcd_item = {1'b1, line2_char(5'd14)};
                    6'd36: get_lcd_item = {1'b1, line2_char(5'd15)};

                    default: get_lcd_item = {1'b1, " "};
                endcase
            end
        end
    endfunction
    // ------------------------------------------------------------
    // LCD byte를 PCF8574 byte 4개로 변환
    //
    // phase 0: upper nibble, EN=1
    // phase 1: upper nibble, EN=0
    // phase 2: lower nibble, EN=1
    // phase 3: lower nibble, EN=0
    // ------------------------------------------------------------
    function [7:0] make_pcf_byte;
        input [7:0] data;
        input rs;
        input [1:0] phase;
        reg [3:0] nibble;
        reg       en;
        begin
            case (phase)
                2'd0: begin
                    nibble = data[7:4];
                    en     = 1'b1;
                end

                2'd1: begin
                    nibble = data[7:4];
                    en     = 1'b0;
                end

                2'd2: begin
                    nibble = data[3:0];
                    en     = 1'b1;
                end

                2'd3: begin
                    nibble = data[3:0];
                    en     = 1'b0;
                end

                default: begin
                    nibble = 4'h0;
                    en     = 1'b0;
                end
            endcase

            // {D7,D6,D5,D4,BL,EN,RW,RS}
            make_pcf_byte = {nibble, 1'b1, en, 1'b0, rs};
        end
    endfunction

    // ------------------------------------------------------------
    // Main FSM
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            state           <= IDLE;

            busy            <= 1'b0;
            done            <= 1'b0;
            ack_error       <= 1'b0;

            i2c_cmd_start   <= 1'b0;
            i2c_cmd_write   <= 1'b0;
            i2c_cmd_stop    <= 1'b0;
            i2c_tx_data     <= 8'd0;

            delay_cnt       <= 32'd0;
            delay_target    <= 32'd0;

            seq_idx         <= 6'd0;
            lcd_byte        <= 8'd0;
            lcd_rs          <= 1'b0;
            pcf_phase       <= 2'd0;
            pcf_byte        <= 8'd0;
            lcd_initialized <= 1'b0;
            seq_full_init   <= 1'b1;
        end else begin
            // command pulse 기본값
            i2c_cmd_start <= 1'b0;
            i2c_cmd_write <= 1'b0;
            i2c_cmd_stop  <= 1'b0;
            done          <= 1'b0;

            if (clr_status) begin
                ack_error <= 1'b0;
            end

            case (state)
                IDLE: begin
                    busy <= 1'b0;

                    if (start) begin
                        busy          <= 1'b1;
                        ack_error     <= 1'b0;

                        seq_idx       <= 6'd0;
                        pcf_phase     <= 2'd0;
                        seq_full_init <= ~lcd_initialized;

                        delay_cnt     <= 32'd0;

                        if (lcd_initialized) begin
                            delay_target <= SHORT_DELAY_CYCLES;
                        end else begin
                            delay_target <= POWER_DELAY_CYCLES;
                        end

                        state <= POWER_WAIT;
                    end
                end

                POWER_WAIT: begin
                    if (delay_cnt >= delay_target) begin
                        delay_cnt <= 32'd0;
                        state     <= LOAD_BYTE;
                    end else begin
                        delay_cnt <= delay_cnt + 1'b1;
                    end
                end

                LOAD_BYTE: begin
                    if ((seq_full_init && (seq_idx >= FULL_SEQ_LEN)) ||
                        (!seq_full_init && (seq_idx >= UPDATE_SEQ_LEN))) begin
                        state <= FINISH;
                    end else begin
                        {lcd_rs, lcd_byte} <= get_lcd_item(seq_idx);
                        pcf_phase          <= 2'd0;
                        state              <= LOAD_PCF;
                    end
                end

                LOAD_PCF: begin
                    pcf_byte <= make_pcf_byte(lcd_byte, lcd_rs, pcf_phase);
                    state    <= SEND_START;
                end

                SEND_START: begin
                    if (!i2c_busy) begin
                        i2c_cmd_start <= 1'b1;
                        state         <= WAIT_START;
                    end
                end

                WAIT_START: begin
                    if (i2c_done) begin
                        state <= SEND_ADDR;
                    end
                end

                SEND_ADDR: begin
                    i2c_tx_data   <= {LCD_ADDR, 1'b0};
                    i2c_cmd_write <= 1'b1;
                    state         <= WAIT_ADDR;
                end

                WAIT_ADDR: begin
                    if (i2c_done) begin
                        if (i2c_ack_out) begin
                            ack_error <= 1'b1;
                        end
                        state <= SEND_DATA;
                    end
                end

                SEND_DATA: begin
                    i2c_tx_data   <= pcf_byte;
                    i2c_cmd_write <= 1'b1;
                    state         <= WAIT_DATA;
                end

                WAIT_DATA: begin
                    if (i2c_done) begin
                        if (i2c_ack_out) begin
                            ack_error <= 1'b1;
                        end
                        state <= SEND_STOP;
                    end
                end

                SEND_STOP: begin
                    i2c_cmd_stop <= 1'b1;
                    state        <= WAIT_STOP;
                end

                WAIT_STOP: begin
                    if (i2c_done) begin
                        state <= NEXT_PCF;
                    end
                end

                NEXT_PCF: begin
                    if (pcf_phase == 2'd3) begin
                        pcf_phase <= 2'd0;

                        // clear display 명령 이후에는 긴 delay
                        if ((seq_full_init && (seq_idx == 6'd6)) ||
                            (!seq_full_init && (seq_idx == 6'd0))) begin
                            delay_target <= CLEAR_DELAY_CYCLES;
                        end else begin
                            delay_target <= SHORT_DELAY_CYCLES;
                        end

                        delay_cnt <= 32'd0;
                        state     <= DELAY;
                    end else begin
                        pcf_phase <= pcf_phase + 1'b1;
                        state     <= LOAD_PCF;
                    end
                end

                DELAY: begin
                    if (delay_cnt >= delay_target) begin
                        delay_cnt <= 32'd0;
                        seq_idx   <= seq_idx + 1'b1;
                        state     <= LOAD_BYTE;
                    end else begin
                        delay_cnt <= delay_cnt + 1'b1;
                    end
                end

                FINISH: begin
                    busy            <= 1'b0;
                    done            <= 1'b1;
                    lcd_initialized <= 1'b1;
                    state           <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule



module i2c_master #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer I2C_FREQ_HZ = 100_000
) (
    input wire clk,
    input wire rst,

    // command port
    input wire cmd_start,
    input wire cmd_write,
    input wire cmd_read,
    input wire cmd_stop,

    // internal port
    input  wire [7:0] tx_data,
    output reg  [7:0] rx_data,
    input  wire       ack_in,
    output reg        ack_out,
    output wire       busy,
    output reg        done,

    // external i2c port
    output wire scl,
    output wire sda_o,
    input  wire sda_i
);

    // ------------------------------------------------------------
    // clog2 function for Verilog
    // ------------------------------------------------------------
    function integer clog2;
        input integer value;
        integer i;
        begin
            value = value - 1;
            for (i = 0; value > 0; i = i + 1) begin
                value = value >> 1;
            end
            clog2 = i;
        end
    endfunction

    // ------------------------------------------------------------
    // State encoding
    // ------------------------------------------------------------
    localparam [2:0] IDLE = 3'd0;
    localparam [2:0] START = 3'd1;
    localparam [2:0] WAIT_CMD = 3'd2;
    localparam [2:0] DATA = 3'd3;
    localparam [2:0] DATA_ACK = 3'd4;
    localparam [2:0] STOP = 3'd5;

    localparam integer QTR_DIV = CLK_FREQ_HZ / (I2C_FREQ_HZ * 4);
    localparam integer DIV_WIDTH = (QTR_DIV <= 1) ? 1 : clog2(QTR_DIV);

    reg [          2:0] state;

    reg [DIV_WIDTH-1:0] div_cnt;
    reg                 qtr_tick;

    reg                 scl_r;
    reg                 sda_r;
    reg [          1:0] step;

    reg [          7:0] tx_shift_reg;
    reg [          7:0] rx_shift_reg;
    reg [          2:0] bit_cnt;

    reg                 is_read;
    reg                 ack_in_r;

    assign scl   = scl_r;
    assign sda_o = sda_r;
    assign busy  = (state != IDLE);

    // ------------------------------------------------------------
    // Quarter SCL tick generator
    // ------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            div_cnt  <= {DIV_WIDTH{1'b0}};
            qtr_tick <= 1'b0;
        end else begin
            if (div_cnt == QTR_DIV - 1) begin
                div_cnt  <= {DIV_WIDTH{1'b0}};
                qtr_tick <= 1'b1;
            end else begin
                div_cnt  <= div_cnt + 1'b1;
                qtr_tick <= 1'b0;
            end
        end
    end

    // ------------------------------------------------------------
    // I2C master FSM
    // ------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;

            scl_r        <= 1'b1;
            sda_r        <= 1'b1;
            step         <= 2'd0;

            done         <= 1'b0;
            ack_out      <= 1'b1;

            tx_shift_reg <= 8'd0;
            rx_shift_reg <= 8'd0;
            rx_data      <= 8'd0;

            bit_cnt      <= 3'd0;
            is_read      <= 1'b0;
            ack_in_r     <= 1'b1;
        end else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    scl_r <= 1'b1;
                    sda_r <= 1'b1;
                    step  <= 2'd0;

                    if (cmd_start) begin
                        state <= START;
                        step  <= 2'd0;
                    end
                end

                START: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                sda_r <= 1'b1;
                                scl_r <= 1'b1;
                                step  <= 2'd1;
                            end

                            2'd1: begin
                                sda_r <= 1'b0;
                                scl_r <= 1'b1;
                                step  <= 2'd2;
                            end

                            2'd2: begin
                                sda_r <= 1'b0;
                                scl_r <= 1'b0;
                                step  <= 2'd3;
                            end

                            2'd3: begin
                                sda_r <= 1'b0;
                                scl_r <= 1'b0;
                                step  <= 2'd0;
                                done  <= 1'b1;
                                state <= WAIT_CMD;
                            end

                            default: begin
                                step <= 2'd0;
                            end
                        endcase
                    end
                end

                WAIT_CMD: begin
                    if (cmd_write) begin
                        tx_shift_reg <= tx_data;
                        bit_cnt      <= 3'd0;
                        is_read      <= 1'b0;
                        step         <= 2'd0;
                        state        <= DATA;
                    end else if (cmd_read) begin
                        rx_shift_reg <= 8'd0;
                        bit_cnt      <= 3'd0;
                        is_read      <= 1'b1;
                        ack_in_r     <= ack_in;
                        step         <= 2'd0;
                        state        <= DATA;
                    end else if (cmd_stop) begin
                        step  <= 2'd0;
                        state <= STOP;
                    end else if (cmd_start) begin
                        step  <= 2'd0;
                        state <= START;
                    end
                end

                DATA: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                scl_r <= 1'b0;

                                // write일 때 1이면 release, 0이면 low drive
                                // read일 때는 release
                                if (is_read) begin
                                    sda_r <= 1'b1;
                                end else begin
                                    sda_r <= tx_shift_reg[7];
                                end

                                step <= 2'd1;
                            end

                            2'd1: begin
                                scl_r <= 1'b1;
                                step  <= 2'd2;
                            end

                            2'd2: begin
                                scl_r <= 1'b1;

                                if (is_read) begin
                                    rx_shift_reg <= {rx_shift_reg[6:0], sda_i};
                                end

                                step <= 2'd3;
                            end

                            2'd3: begin
                                scl_r <= 1'b0;
                                step  <= 2'd0;

                                if (!is_read) begin
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                end

                                if (bit_cnt == 3'd7) begin
                                    state <= DATA_ACK;
                                end else begin
                                    bit_cnt <= bit_cnt + 1'b1;
                                end
                            end

                            default: begin
                                step <= 2'd0;
                            end
                        endcase
                    end
                end

                DATA_ACK: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                scl_r <= 1'b0;

                                if (is_read) begin
                                    // master가 slave에게 ACK/NACK 전송
                                    sda_r <= ack_in_r;
                                end else begin
                                    // slave ACK 받기 위해 SDA release
                                    sda_r <= 1'b1;
                                end

                                step <= 2'd1;
                            end

                            2'd1: begin
                                scl_r <= 1'b1;
                                step  <= 2'd2;
                            end

                            2'd2: begin
                                scl_r <= 1'b1;

                                if (!is_read) begin
                                    // ACK = 0, NACK = 1
                                    ack_out <= sda_i;
                                end else begin
                                    rx_data <= rx_shift_reg;
                                end

                                step <= 2'd3;
                            end

                            2'd3: begin
                                scl_r <= 1'b0;
                                step  <= 2'd0;
                                done  <= 1'b1;
                                state <= WAIT_CMD;
                            end

                            default: begin
                                step <= 2'd0;
                            end
                        endcase
                    end
                end

                STOP: begin
                    if (qtr_tick) begin
                        case (step)
                            2'd0: begin
                                sda_r <= 1'b0;
                                scl_r <= 1'b0;
                                step  <= 2'd1;
                            end

                            2'd1: begin
                                sda_r <= 1'b0;
                                scl_r <= 1'b1;
                                step  <= 2'd2;
                            end

                            2'd2: begin
                                sda_r <= 1'b1;
                                scl_r <= 1'b1;
                                step  <= 2'd3;
                            end

                            2'd3: begin
                                sda_r <= 1'b1;
                                scl_r <= 1'b1;
                                step  <= 2'd0;
                                done  <= 1'b1;
                                state <= IDLE;
                            end

                            default: begin
                                step <= 2'd0;
                            end
                        endcase
                    end
                end

                default: begin
                    state <= IDLE;
                    scl_r <= 1'b1;
                    sda_r <= 1'b1;
                    step  <= 2'd0;
                end
            endcase
        end
    end

endmodule
