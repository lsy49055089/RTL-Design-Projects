// UVM environment for IP-level AXI-Lite SPI peripheral verification.
class env extends uvm_env;
    `uvm_component_utils(env)

    uvm_sequencer #(axi_lite_transaction) axi_seqr;
    axi_lite_driver                         axi_drv;
    axi_lite_monitor                        axi_mon;
    spi_monitor                             spi_mon;
    scoreboard                              scb;
    spi_axi_coverage                        cov;

    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_seqr = new("axi_seqr", this);
        axi_drv  = axi_lite_driver::type_id::create("axi_drv", this);
        axi_mon  = axi_lite_monitor::type_id::create("axi_mon", this);
        spi_mon  = spi_monitor::type_id::create("spi_mon", this);
        scb      = scoreboard::type_id::create("scb", this);
        cov      = spi_axi_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        axi_drv.seq_item_port.connect(axi_seqr.seq_item_export);
        axi_mon.ap.connect(scb.axi_fifo.analysis_export);
        spi_mon.ap.connect(scb.spi_fifo.analysis_export);
        axi_mon.ap.connect(cov.axi_fifo.analysis_export);
        spi_mon.ap.connect(cov.spi_fifo.analysis_export);
    endfunction
endclass
