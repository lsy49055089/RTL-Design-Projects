// Functional coverage for register accesses and SPI transaction completion.
class spi_axi_coverage extends uvm_component;
    `uvm_component_utils(spi_axi_coverage)

    uvm_tlm_analysis_fifo #(axi_lite_transaction) axi_fifo;
    uvm_tlm_analysis_fifo #(axi_lite_transaction) spi_fifo;

    covergroup txdata_cg with function sample(bit [7:0] value);
        option.per_instance = 1;
        cp_txdata: coverpoint value {
            bins zero    = {8'h00};
            bins all_one = {8'hFF};
            bins a5      = {8'hA5};
            bins five_a  = {8'h5A};
            bins others[] = default;
        }
    endgroup

    covergroup start_cg with function sample(bit value);
        option.per_instance = 1;
        cp_start: coverpoint value {
            bins start_write = {1'b1};
        }
    endgroup

    covergroup done_cg with function sample(bit value);
        option.per_instance = 1;
        cp_done: coverpoint value {
            bins done_seen = {1'b1};
        }
    endgroup

    covergroup spi_complete_cg with function sample(bit value);
        option.per_instance = 1;
        cp_complete: coverpoint value {
            bins complete = {1'b1};
        }
    endgroup

    function new(string name = "spi_axi_coverage", uvm_component parent = null);
        super.new(name, parent);
        txdata_cg       = new();
        start_cg        = new();
        done_cg         = new();
        spi_complete_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_fifo = new("axi_fifo", this);
        spi_fifo = new("spi_fifo", this);
    endfunction

    task process_axi();
        axi_lite_transaction tr;

        forever begin
            axi_fifo.get(tr);

            if (tr.kind == AXI_LITE_ITEM_WRITE) begin
                if (tr.addr == SPI_AXI_TXDATA_ADDR) begin
                    txdata_cg.sample(tr.data[7:0]);
                end

                if ((tr.addr == SPI_AXI_CR_ADDR) && tr.data[0]) begin
                    start_cg.sample(1'b1);
                end
            end else if (tr.kind == AXI_LITE_ITEM_READ) begin
                if ((tr.addr == SPI_AXI_SR_ADDR) && tr.rdata[1]) begin
                    done_cg.sample(1'b1);
                end
            end
        end
    endtask

    task process_spi();
        axi_lite_transaction tr;

        forever begin
            spi_fifo.get(tr);
            spi_complete_cg.sample(tr.spi_complete);
        end
    endtask

    task run_phase(uvm_phase phase);
        fork
            process_axi();
            process_spi();
        join
    endtask

    function void report_phase(uvm_phase phase);
        real tx_cov;
        real start_cov;
        real done_cov;
        real spi_cov;
        real total_cov;

        super.report_phase(phase);

        tx_cov    = txdata_cg.get_inst_coverage();
        start_cov = start_cg.get_inst_coverage();
        done_cov  = done_cg.get_inst_coverage();
        spi_cov   = spi_complete_cg.get_inst_coverage();
        total_cov = (tx_cov + start_cov + done_cov + spi_cov) / 4.0;

        `uvm_info("COV", $sformatf({
                  "\n================================================\n",
                  " SPI AXI FUNCTIONAL COVERAGE\n",
                  " TOTAL              : %0.2f %%\n",
                  " TXDATA             : %0.2f %%\n",
                  " START_WRITE        : %0.2f %%\n",
                  " DONE_STATUS        : %0.2f %%\n",
                  " SPI_COMPLETE       : %0.2f %%\n",
                  "================================================"},
                  total_cov, tx_cov, start_cov, done_cov, spi_cov), UVM_NONE)
    endfunction
endclass
