`timescale 1ns / 1ps

// AXI4-Lite master-side interface for the IP-level UVM testbench.
interface axi_lite_if #(
    parameter int ADDR_WIDTH = 4,
    parameter int DATA_WIDTH = 32
) (
    input logic ACLK
);

    logic ARESETN;

    logic [ADDR_WIDTH-1:0]     AWADDR;
    logic [2:0]                AWPROT;
    logic                      AWVALID;
    logic                      AWREADY;
    logic [DATA_WIDTH-1:0]     WDATA;
    logic [(DATA_WIDTH/8)-1:0] WSTRB;
    logic                      WVALID;
    logic                      WREADY;
    logic [1:0]                BRESP;
    logic                      BVALID;
    logic                      BREADY;

    logic [ADDR_WIDTH-1:0] ARADDR;
    logic [2:0]            ARPROT;
    logic                  ARVALID;
    logic                  ARREADY;
    logic [DATA_WIDTH-1:0] RDATA;
    logic [1:0]            RRESP;
    logic                  RVALID;
    logic                  RREADY;

    initial begin
        ARESETN = 1'b0;
        AWADDR  = '0;
        AWPROT  = 3'b000;
        AWVALID = 1'b0;
        WDATA   = '0;
        WSTRB   = '0;
        WVALID  = 1'b0;
        BREADY  = 1'b0;
        ARADDR  = '0;
        ARPROT  = 3'b000;
        ARVALID = 1'b0;
        RREADY  = 1'b0;
    end

    clocking mon_cb @(posedge ACLK);
        default input #1step output #0;
        input ARESETN;
        input AWADDR;
        input AWPROT;
        input AWVALID;
        input AWREADY;
        input WDATA;
        input WSTRB;
        input WVALID;
        input WREADY;
        input BRESP;
        input BVALID;
        input BREADY;
        input ARADDR;
        input ARPROT;
        input ARVALID;
        input ARREADY;
        input RDATA;
        input RRESP;
        input RVALID;
        input RREADY;
    endclocking

endinterface
