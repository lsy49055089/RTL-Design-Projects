// Scoreboard compares AXI TXDATA/RXDATA against observed SPI MOSI/MISO.
class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard)

    uvm_tlm_analysis_fifo #(axi_lite_transaction) axi_fifo;
    uvm_tlm_analysis_fifo #(axi_lite_transaction) spi_fifo;

    bit [7:0] tx_q[$];
    bit [7:0] axi_rx_q[$];
    bit [7:0] spi_mosi_q[$];
    bit [7:0] spi_miso_q[$];

    int pass_count;
    int fail_count;
    int start_count;
    int done_count;
    int check_count;

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_fifo = new("axi_fifo", this);
        spi_fifo = new("spi_fifo", this);
    endfunction

    function void compare_mosi();
        bit [7:0] expected;
        bit [7:0] observed;

        while ((tx_q.size() > 0) && (spi_mosi_q.size() > 0)) begin
            expected = tx_q.pop_front();
            observed = spi_mosi_q.pop_front();

            if (observed === expected) begin
                check_count++;
                pass_count++;
                `uvm_info("SCB", $sformatf("PASS MOSI expected=0x%02h observed=0x%02h",
                                           expected, observed), UVM_LOW)
            end else begin
                check_count++;
                fail_count++;
                `uvm_error("SCB", $sformatf("MOSI mismatch expected TXDATA=0x%02h observed=0x%02h",
                                            expected, observed))
            end
        end
    endfunction

    function void compare_miso_rx();
        bit [7:0] expected;
        bit [7:0] observed;

        while ((spi_miso_q.size() > 0) && (axi_rx_q.size() > 0)) begin
            expected = spi_miso_q.pop_front();
            observed = axi_rx_q.pop_front();

            if (observed === expected) begin
                check_count++;
                pass_count++;
                `uvm_info("SCB", $sformatf("PASS RXDATA expected MISO=0x%02h observed=0x%02h",
                                           expected, observed), UVM_LOW)
            end else begin
                check_count++;
                fail_count++;
                `uvm_error("SCB", $sformatf("RXDATA mismatch expected MISO=0x%02h observed=0x%02h",
                                            expected, observed))
            end
        end
    endfunction

    task process_axi();
        axi_lite_transaction tr;

        forever begin
            axi_fifo.get(tr);

            if (tr.kind == AXI_LITE_ITEM_WRITE) begin
                if (tr.addr == SPI_AXI_TXDATA_ADDR) begin
                    tx_q.push_back(tr.data[7:0]);
                    compare_mosi();
                end

                if ((tr.addr == SPI_AXI_CR_ADDR) && tr.data[0]) begin
                    start_count++;
                end
            end else if (tr.kind == AXI_LITE_ITEM_READ) begin
                if ((tr.addr == SPI_AXI_SR_ADDR) && tr.rdata[1]) begin
                    done_count++;
                end

                if (tr.addr == SPI_AXI_RXDATA_ADDR) begin
                    axi_rx_q.push_back(tr.rdata[7:0]);
                    compare_miso_rx();
                end
            end
        end
    endtask

    task process_spi();
        axi_lite_transaction tr;

        forever begin
            spi_fifo.get(tr);

            if (!tr.spi_complete) begin
                fail_count++;
                `uvm_error("SCB", "Incomplete SPI transaction observed")
            end else begin
                spi_mosi_q.push_back(tr.spi_mosi_data);
                spi_miso_q.push_back(tr.spi_miso_data);
                compare_mosi();
                compare_miso_rx();
            end
        end
    endtask

    task run_phase(uvm_phase phase);
        fork
            process_axi();
            process_spi();
        join
    endtask

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);

        if ((tx_q.size() != 0) || (axi_rx_q.size() != 0) ||
            (spi_mosi_q.size() != 0) || (spi_miso_q.size() != 0)) begin
            `uvm_error("SCB", $sformatf("Unmatched queues remain tx=%0d axi_rx=%0d spi_mosi=%0d spi_miso=%0d",
                                        tx_q.size(), axi_rx_q.size(),
                                        spi_mosi_q.size(), spi_miso_q.size()))
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB", $sformatf({
                  "\n================================================\n",
                  " SPI AXI SCOREBOARD FINAL REPORT\n",
                  " CHECK COUNT        : %0d\n",
                  " PASS COUNT         : %0d\n",
                  " FAIL COUNT         : %0d\n",
                  " START WRITE COUNT  : %0d\n",
                  " DONE READ COUNT    : %0d\n",
                  "================================================"},
                  check_count, pass_count, fail_count, start_count, done_count), UVM_NONE)
    endfunction
endclass
