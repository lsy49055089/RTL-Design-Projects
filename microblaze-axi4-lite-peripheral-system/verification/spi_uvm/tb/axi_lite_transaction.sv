// Common sequence item and register constants for the SPI AXI-Lite UVM env.
localparam bit [3:0] SPI_AXI_CR_ADDR     = 4'h0;
localparam bit [3:0] SPI_AXI_TXDATA_ADDR = 4'h4;
localparam bit [3:0] SPI_AXI_RXDATA_ADDR = 4'h8;
localparam bit [3:0] SPI_AXI_SR_ADDR     = 4'hC;

typedef enum int {
    AXI_LITE_ITEM_TRANSFER,
    AXI_LITE_ITEM_WRITE,
    AXI_LITE_ITEM_READ,
    AXI_LITE_ITEM_SPI
} axi_lite_item_kind_e;

class axi_lite_transaction extends uvm_sequence_item;
    rand axi_lite_item_kind_e kind;
    rand bit [7:0]            tx_data;
    rand bit [7:0]            slave_tx_data;
    rand bit [7:0]            clk_div;

    bit [3:0]  addr;
    bit [31:0] data;
    bit [31:0] rdata;
    bit [1:0]  resp;

    bit [7:0] rx_data;
    bit       start_write;
    bit       done_status;
    bit       spi_complete;
    bit [7:0] spi_mosi_data;
    bit [7:0] spi_miso_data;

    constraint c_clk_div {
        clk_div inside {[8'd2:8'd20]};
    }

    `uvm_object_utils_begin(axi_lite_transaction)
        `uvm_field_enum(axi_lite_item_kind_e, kind, UVM_ALL_ON)
        `uvm_field_int(tx_data, UVM_ALL_ON)
        `uvm_field_int(slave_tx_data, UVM_ALL_ON)
        `uvm_field_int(clk_div, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_int(resp, UVM_ALL_ON)
        `uvm_field_int(rx_data, UVM_ALL_ON)
        `uvm_field_int(start_write, UVM_ALL_ON)
        `uvm_field_int(done_status, UVM_ALL_ON)
        `uvm_field_int(spi_complete, UVM_ALL_ON)
        `uvm_field_int(spi_mosi_data, UVM_ALL_ON)
        `uvm_field_int(spi_miso_data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi_lite_transaction");
        super.new(name);
        kind          = AXI_LITE_ITEM_TRANSFER;
        clk_div       = 8'd8;
        tx_data       = 8'h00;
        slave_tx_data = 8'h00;
    endfunction

    function string convert2string();
        return $sformatf("kind=%0d addr=0x%0h data=0x%08h rdata=0x%08h tx=0x%02h slave_tx=0x%02h mosi=0x%02h miso=0x%02h",
                         kind, addr, data, rdata, tx_data, slave_tx_data,
                         spi_mosi_data, spi_miso_data);
    endfunction
endclass
