// AXI4-Lite driver that performs one register read/write at a time.
class axi_lite_driver extends uvm_driver #(axi_lite_transaction);
    `uvm_component_utils(axi_lite_driver)

    virtual axi_lite_if axi_vif;
    virtual spi_if      spi_vif;

    function new(string name = "axi_lite_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "axi_vif", axi_vif)) begin
            `uvm_fatal("AXI_DRV", "Failed to get axi_vif from config_db")
        end
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "spi_vif", spi_vif)) begin
            `uvm_fatal("AXI_DRV", "Failed to get spi_vif from config_db")
        end
    endfunction

    task drive_idle();
        axi_vif.AWADDR  = '0;
        axi_vif.AWPROT  = 3'b000;
        axi_vif.AWVALID = 1'b0;
        axi_vif.WDATA   = '0;
        axi_vif.WSTRB   = '0;
        axi_vif.WVALID  = 1'b0;
        axi_vif.BREADY  = 1'b0;
        axi_vif.ARADDR  = '0;
        axi_vif.ARPROT  = 3'b000;
        axi_vif.ARVALID = 1'b0;
        axi_vif.RREADY  = 1'b0;
    endtask

    task reset_dut();
        drive_idle();
        spi_vif.slave_tx_data = 8'h00;
        axi_vif.ARESETN       = 1'b0;
        repeat (8) @(posedge axi_vif.ACLK);
        axi_vif.ARESETN = 1'b1;
        repeat (4) @(posedge axi_vif.ACLK);
    endtask

    task wait_ready_pair(output int cycles);
        cycles = 0;
        do begin
            @(posedge axi_vif.ACLK);
            #1ps;
            cycles++;
            if (cycles > 100) begin
                `uvm_fatal("AXI_DRV", "AXI write address/data ready timeout")
            end
        end while (!(axi_vif.AWREADY && axi_vif.WREADY));
    endtask

    task write_reg(bit [3:0] addr, bit [31:0] data);
        int cycles;

        @(negedge axi_vif.ACLK);
        axi_vif.AWADDR  = addr;
        axi_vif.AWPROT  = 3'b000;
        axi_vif.AWVALID = 1'b1;
        axi_vif.WDATA   = data;
        axi_vif.WSTRB   = 4'hF;
        axi_vif.WVALID  = 1'b1;
        axi_vif.BREADY  = 1'b1;

        wait_ready_pair(cycles);

        // Hold VALID through the clock edge where READY is sampled high.
        @(posedge axi_vif.ACLK);
        #1ps;

        @(negedge axi_vif.ACLK);
        axi_vif.AWVALID = 1'b0;
        axi_vif.WVALID  = 1'b0;
        axi_vif.AWADDR  = '0;
        axi_vif.WDATA   = '0;
        axi_vif.WSTRB   = '0;

        cycles = 0;
        while (!axi_vif.BVALID) begin
            @(posedge axi_vif.ACLK);
            #1ps;
            cycles++;
            if (cycles > 100) begin
                `uvm_fatal("AXI_DRV", "AXI write response timeout")
            end
        end

        if (axi_vif.BRESP != 2'b00) begin
            `uvm_error("AXI_DRV", $sformatf("AXI write BRESP error addr=0x%0h resp=%0b", addr, axi_vif.BRESP))
        end

        do begin
            @(posedge axi_vif.ACLK);
            #1ps;
        end while (axi_vif.BVALID);

        @(negedge axi_vif.ACLK);
        axi_vif.BREADY = 1'b0;
    endtask

    task read_reg(bit [3:0] addr, output bit [31:0] data);
        int cycles;

        @(negedge axi_vif.ACLK);
        axi_vif.ARADDR  = addr;
        axi_vif.ARPROT  = 3'b000;
        axi_vif.ARVALID = 1'b1;
        axi_vif.RREADY  = 1'b1;

        cycles = 0;
        do begin
            @(posedge axi_vif.ACLK);
            #1ps;
            cycles++;
            if (cycles > 100) begin
                `uvm_fatal("AXI_DRV", "AXI read address ready timeout")
            end
        end while (!axi_vif.ARREADY);

        // Keep ARVALID asserted through the address acceptance clock.
        @(posedge axi_vif.ACLK);
        #1ps;

        cycles = 0;
        while (!axi_vif.RVALID) begin
            @(posedge axi_vif.ACLK);
            #1ps;
            cycles++;
            if (cycles > 100) begin
                `uvm_fatal("AXI_DRV", "AXI read data timeout")
            end
        end

        data = axi_vif.RDATA;
        if (axi_vif.RRESP != 2'b00) begin
            `uvm_error("AXI_DRV", $sformatf("AXI read RRESP error addr=0x%0h resp=%0b", addr, axi_vif.RRESP))
        end

        @(negedge axi_vif.ACLK);
        axi_vif.ARVALID = 1'b0;
        axi_vif.ARADDR  = '0;

        do begin
            @(posedge axi_vif.ACLK);
            #1ps;
        end while (axi_vif.RVALID);

        @(negedge axi_vif.ACLK);
        axi_vif.RREADY = 1'b0;
    endtask

    task wait_done(output bit [31:0] sr_value);
        int poll_count;

        poll_count = 0;
        do begin
            read_reg(SPI_AXI_SR_ADDR, sr_value);
            if (!sr_value[1]) begin
                repeat (2) @(posedge axi_vif.ACLK);
            end
            poll_count++;
            if (poll_count > 1000) begin
                `uvm_fatal("AXI_DRV", "Timeout waiting for SR.DONE")
            end
        end while (!sr_value[1]);
    endtask

    task drive_transfer(axi_lite_transaction tr);
        bit [31:0] sr_value;
        bit [31:0] rx_value;
        bit [31:0] cr_value;

        if (tr.kind != AXI_LITE_ITEM_TRANSFER) begin
            `uvm_warning("AXI_DRV", $sformatf("Ignoring non-transfer item: %s", tr.convert2string()))
            return;
        end

        `uvm_info("AXI_DRV", $sformatf("TXDATA=0x%02h slave_miso=0x%02h clk_div=%0d",
                                       tr.tx_data, tr.slave_tx_data, tr.clk_div), UVM_MEDIUM)

        spi_vif.slave_tx_data = tr.slave_tx_data;

        write_reg(SPI_AXI_TXDATA_ADDR, {24'd0, tr.tx_data});
        cr_value = {16'd0, tr.clk_div, 6'd0, 1'b0, 1'b1};
        write_reg(SPI_AXI_CR_ADDR, cr_value);
        wait_done(sr_value);
        read_reg(SPI_AXI_RXDATA_ADDR, rx_value);

        tr.rx_data = rx_value[7:0];
        `uvm_info("AXI_DRV", $sformatf("Transfer completed SR=0x%08h RXDATA=0x%02h",
                                       sr_value, tr.rx_data), UVM_MEDIUM)
    endtask

    task run_phase(uvm_phase phase);
        axi_lite_transaction tr;

        reset_dut();

        forever begin
            seq_item_port.get_next_item(tr);
            drive_transfer(tr);
            seq_item_port.item_done();
        end
    endtask
endclass
