// AXI4-Lite monitor that publishes accepted single read/write transfers.
class axi_lite_monitor extends uvm_component;
    `uvm_component_utils(axi_lite_monitor)

    virtual axi_lite_if axi_vif;
    uvm_analysis_port #(axi_lite_transaction) ap;

    function new(string name = "axi_lite_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "axi_vif", axi_vif)) begin
            `uvm_fatal("AXI_MON", "Failed to get axi_vif from config_db")
        end
    endfunction

    task run_phase(uvm_phase phase);
        bit pending_read;
        bit [3:0] pending_read_addr;
        axi_lite_transaction tr;

        pending_read      = 1'b0;
        pending_read_addr = '0;

        forever begin
            @(axi_vif.mon_cb);

            if (!axi_vif.mon_cb.ARESETN) begin
                pending_read      = 1'b0;
                pending_read_addr = '0;
            end else begin
                if (axi_vif.mon_cb.AWVALID && axi_vif.mon_cb.AWREADY &&
                    axi_vif.mon_cb.WVALID && axi_vif.mon_cb.WREADY) begin
                    tr             = axi_lite_transaction::type_id::create("axi_write_tr");
                    tr.kind        = AXI_LITE_ITEM_WRITE;
                    tr.addr        = axi_vif.mon_cb.AWADDR;
                    tr.data        = axi_vif.mon_cb.WDATA;
                    tr.resp        = axi_vif.mon_cb.BRESP;
                    tr.tx_data     = axi_vif.mon_cb.WDATA[7:0];
                    tr.start_write = (tr.addr == SPI_AXI_CR_ADDR) && tr.data[0];
                    ap.write(tr);
                end

                if (axi_vif.mon_cb.ARVALID && axi_vif.mon_cb.ARREADY) begin
                    pending_read      = 1'b1;
                    pending_read_addr = axi_vif.mon_cb.ARADDR;
                end

                if (pending_read && axi_vif.mon_cb.RVALID && axi_vif.mon_cb.RREADY) begin
                    tr              = axi_lite_transaction::type_id::create("axi_read_tr");
                    tr.kind         = AXI_LITE_ITEM_READ;
                    tr.addr         = pending_read_addr;
                    tr.rdata        = axi_vif.mon_cb.RDATA;
                    tr.resp         = axi_vif.mon_cb.RRESP;
                    tr.rx_data      = axi_vif.mon_cb.RDATA[7:0];
                    tr.done_status  = (tr.addr == SPI_AXI_SR_ADDR) && tr.rdata[1];
                    ap.write(tr);
                    pending_read = 1'b0;
                end
            end
        end
    endtask
endclass
