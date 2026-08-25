// Top-level UVM test that starts the directed/random AXI-Lite SPI sequence.
class spi_axi_test extends uvm_test;
    `uvm_component_utils(spi_axi_test)

    env m_env;

    function new(string name = "spi_axi_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_env = env::type_id::create("m_env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        axi_lite_sequence seq;

        phase.raise_objection(this);
        uvm_top.set_timeout(2000000ns, 1);

        seq = axi_lite_sequence::type_id::create("seq");
        seq.start(m_env.axi_seqr);

        #1000ns;
        phase.drop_objection(this);
    endtask
endclass
