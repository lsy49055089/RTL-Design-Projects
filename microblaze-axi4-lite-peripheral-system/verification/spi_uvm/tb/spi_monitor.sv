// Passive SPI monitor that reconstructs MOSI/MISO bytes from CS_N/SCLK.
class spi_monitor extends uvm_component;
    `uvm_component_utils(spi_monitor)

    virtual spi_if spi_vif;
    uvm_analysis_port #(axi_lite_transaction) ap;

    function new(string name = "spi_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "spi_vif", spi_vif)) begin
            `uvm_fatal("SPI_MON", "Failed to get spi_vif from config_db")
        end
    endfunction

    task run_phase(uvm_phase phase);
        axi_lite_transaction tr;
        bit [7:0] mosi_shift;
        bit [7:0] miso_shift;
        int bit_count;

        forever begin
            wait (spi_vif.cs_n === 1'b1);
            @(negedge spi_vif.cs_n);

            tr         = axi_lite_transaction::type_id::create("spi_observed_tr");
            tr.kind    = AXI_LITE_ITEM_SPI;
            mosi_shift = 8'h00;
            miso_shift = 8'h00;
            bit_count  = 0;

            while ((spi_vif.cs_n === 1'b0) && (bit_count < 8)) begin
                @(posedge spi_vif.sclk or posedge spi_vif.cs_n);
                if (spi_vif.cs_n === 1'b0) begin
                    #1ps;
                    mosi_shift = {mosi_shift[6:0], spi_vif.mosi};
                    miso_shift = {miso_shift[6:0], spi_vif.miso};
                    bit_count++;
                end
            end

            if (spi_vif.cs_n === 1'b0) begin
                @(posedge spi_vif.cs_n);
            end

            tr.spi_mosi_data = mosi_shift;
            tr.spi_miso_data = miso_shift;
            tr.spi_complete  = (bit_count == 8);

            `uvm_info("SPI_MON", $sformatf("SPI complete=%0b MOSI=0x%02h MISO=0x%02h bits=%0d",
                                           tr.spi_complete, tr.spi_mosi_data,
                                           tr.spi_miso_data, bit_count), UVM_MEDIUM)
            ap.write(tr);
        end
    endtask
endclass
