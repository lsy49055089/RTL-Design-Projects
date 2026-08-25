`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/07 15:43:17
// Design Name: 
// Module Name: fnd_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fnd_controller #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input                      clk,
    input                      rst,
    input                      sw,    // sw[0], 0 : msec_sec, 1 : min_hour
    input [MSEC_WIDTH  -1 : 0] msec,
    input [ SEC_WIDTH - 1 : 0] sec,
    input [ MIN_WIDTH - 1 : 0] min,
    input [HOUR_WIDTH - 1 : 0] hour,

    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire w_1khz;
    wire [3:0] w_out_mux, w_out_mux_msec_sec, w_out_mux_min_hour;
    wire [3:0] w_msec_digit_1, w_msec_digit_10;
    wire [3:0] w_sec_digit_1, w_sec_digit_10;
    wire [3:0] w_min_digit_1, w_min_digit_10;
    wire [3:0] w_hour_digit_1, w_hour_digit_10;

    wire [2:0] w_digit_sel;
    wire w_dot_onoff;

    //digit spliter
    digit_splitter #(
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_DS (

        .digit_in(msec),
        .digit_1 (w_msec_digit_1),
        .digit_10(w_msec_digit_10)
    );



    digit_splitter #(
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_DS (

        .digit_in(sec),
        .digit_1 (w_sec_digit_1),
        .digit_10(w_sec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_DS (

        .digit_in(min),
        .digit_1 (w_min_digit_1),
        .digit_10(w_min_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_DS (

        .digit_in(hour),
        .digit_1 (w_hour_digit_1),
        .digit_10(w_hour_digit_10)
    );



    comparator U_COMP (
        .comp_in  (msec),
        .dot_onoff(w_dot_onoff)
    );

    mux_8x1 U_MUX_MSEC_SEC (
        .in0(w_msec_digit_1),   //msec digit 1
        .in1(w_msec_digit_10),  //msec digit 10
        .in2(w_sec_digit_1),    //sec digit 1
        .in3(w_sec_digit_10),   //sec digit 10

        .in4(4'hf),                   //msec digit 1
        .in5(4'hf),                   //msec digit 10
        .in6({3'b111, w_dot_onoff}),  //sec digit 1 dot display
        .in7(4'hf),                   //sec digit 10

        .sel    (w_digit_sel),        // to select digit
        .out_mux(w_out_mux_msec_sec)

    );

    mux_8x1 U_MUX_MIN_HOUR (
        .in0(w_min_digit_1),   //msec digit 1
        .in1(w_min_digit_10),  //msec digit 10
        .in2(w_hour_digit_1),  //sec digit 1
        .in3(w_hour_digit_10), //sec digit 10

        .in4(4'hf),            //msec digit 1
        .in5(4'hf),            //msec digit 10
        .in6({3'b111, w_dot_onoff}),  //sec digit 1 dot display
        .in7(4'hf),            //sec digit 10

        .sel    (w_digit_sel),        // to select digit
        .out_mux(w_out_mux_min_hour)

    );

    mux_2x1 U_MUX_2x1 (
        .in0(w_out_mux_msec_sec),
        .in1(w_out_mux_min_hour),
        .sel(sw),
        .out_mux(w_out_mux)
    );




    BCD_decoder U_BCD (
        .bin(w_out_mux),
        .bcd_data(fnd_data)
    );

    clk_div_1khz U_CLK_DIV_1KHZ (
        .clk(clk),
        .rst(rst),
        .o_1khz(w_1khz)
    );


    counter_8 U_COUNTER_8 (
        .clk(w_1khz),
        .rst(rst),
        .digit_sel(w_digit_sel)
    );



    decoder_2x4 U_DECODER_2x4 (
        .decoder_in(w_digit_sel[1:0]),
        .fnd_com(fnd_com)
    );






endmodule





module digit_splitter #(
    parameter BIT_WIDTH = 7
) (

    input [BIT_WIDTH - 1:0] digit_in,
    output [3:0] digit_1,
    output [3:0] digit_10
);


    assign digit_1  = digit_in % 10;  // digit 1
    assign digit_10 = (digit_in / 10) % 10;  // digit 10





endmodule




module mux_8x1 (
    input [3:0] in0,  //msec digit 1
    input [3:0] in1,  //msec digit 10
    input [3:0] in2,  //sec digit 1
    input [3:0] in3,  //secdigit 10
    input [3:0] in4,  //min digit 1
    input [3:0] in5,  //min digit 10
    input [3:0] in6,  //hour digit 100
    input [3:0] in7,  //hour digit 1000
    input [2:0] sel,  // to select digit
    output [3:0] out_mux

);
    reg [3:0] out_reg;
    assign out_mux = out_reg;

    // mux, * = all input : sensitivity list

    always @(*) begin
        case (sel)
            3'b000:  out_reg = in0;
            3'b001:  out_reg = in1;
            3'b010:  out_reg = in2;
            3'b011:  out_reg = in3;
            3'b100:  out_reg = in4;
            3'b101:  out_reg = in5;
            3'b110:  out_reg = in6;
            3'b111:  out_reg = in7;
            default: out_reg = 4'b0000;
        endcase


    end

endmodule




module mux_2x1 (
    input [3:0] in0,
    input [3:0] in1,
    input sel,
    output [3:0] out_mux
);

    assign out_mux = (sel) ? in1 : in0;  // in0 = msec_sec, in1 = min_hour

endmodule




module BCD_decoder (

    input      [3:0] bin,
    output reg [7:0] bcd_data

);

    always @(bin) begin
        case (bin)
            4'b0000: bcd_data = 8'hc0;  //1
            4'b0001: bcd_data = 8'hf9;  //2
            4'b0010: bcd_data = 8'ha4;  //3
            4'b0011: bcd_data = 8'hb0;  //4
            4'b0100: bcd_data = 8'h99;  //5
            4'b0101: bcd_data = 8'h92;  //6
            4'b0110: bcd_data = 8'h82;  //7
            4'b0111: bcd_data = 8'hf8;  //8

            4'b1000: bcd_data = 8'h80;  //9
            4'b1001: bcd_data = 8'h90;  //a
            4'b1010: bcd_data = 8'h88;  //b
            4'b1011: bcd_data = 8'h83;  //c
            4'b1100: bcd_data = 8'hc6;  //d
            4'b1101: bcd_data = 8'ha1;  //e
            4'b1110: bcd_data = 8'h7f;  //dot on
            4'b1111: bcd_data = 8'hff;  //all off
            default: bcd_data = 8'hff;
        endcase

    end

endmodule





module clk_div_1khz (
    input  clk,
    input  rst,
    output o_1khz
);


    reg [15:0] counter_reg;
    reg o_1khz_reg;

    assign o_1khz = o_1khz_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 16'd0;
            o_1khz_reg  <= 1'b0;  //
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (50_000 - 1)) begin
                counter_reg <= 16'd0;
                o_1khz_reg  <= ~o_1khz_reg;
            end
        end
    end

endmodule





module counter_8 (
    input clk,
    input rst,
    output [2:0] digit_sel
);

    reg [2:0] counter_reg;

    assign digit_sel = counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_reg + 1;

        end


    end



endmodule




module decoder_2x4 (
    input      [1:0] decoder_in,
    output reg [3:0] fnd_com
);


    always @(*) begin
        case (decoder_in)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end

endmodule


module comparator (
    input [6:0] comp_in,
    output dot_onoff
);

    assign dot_onoff = (comp_in > 7'd49);


endmodule
