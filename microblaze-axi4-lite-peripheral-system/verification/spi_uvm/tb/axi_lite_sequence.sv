// Directed and random SPI-over-AXI transfer sequence.
class axi_lite_sequence extends uvm_sequence #(axi_lite_transaction);
    `uvm_object_utils(axi_lite_sequence)

    function new(string name = "axi_lite_sequence");
        super.new(name);
    endfunction

    task send_transfer(bit [7:0] tx_value, bit [7:0] slave_value);
        axi_lite_transaction tr;

        tr = axi_lite_transaction::type_id::create($sformatf("transfer_%02h", tx_value));
        start_item(tr);
        tr.kind          = AXI_LITE_ITEM_TRANSFER;
        tr.tx_data       = tx_value;
        tr.slave_tx_data = slave_value;
        tr.clk_div       = 8'd8;
        finish_item(tr);
    endtask

    virtual task body();
        axi_lite_transaction tr;

        send_transfer(8'h00, 8'hFF);
        send_transfer(8'hFF, 8'h00);
        send_transfer(8'hA5, 8'h5A);
        send_transfer(8'h5A, 8'hA5);

        repeat (12) begin
            tr = axi_lite_transaction::type_id::create("random_transfer");
            start_item(tr);
            if (!tr.randomize() with { clk_div == 8'd8; }) begin
                `uvm_error("AXI_SEQ", "Randomization failed")
            end
            tr.kind          = AXI_LITE_ITEM_TRANSFER;
            tr.slave_tx_data = ~tr.tx_data;
            finish_item(tr);
        end
    endtask
endclass
