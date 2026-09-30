`timescale 1ns / 1ps

// Uses the original CPU and data-memory RTL. A simulation-only instruction
// ROM loads an explicit image without changing the coursework smoke-test ROM.
module tb_sort_reproduction;
    logic clk = 0;
    logic rst = 1;
    logic [31:0] instr_code, drdata, instr_addr, daddr, dwdata;
    logic [2:0] mem_mode;
    logic dwe;
    logic [31:0] rom [0:511];
    integer words, legacy_mode, cycles;
    integer expected [0:5];
    integer result_base, result_count, terminal_pc;
    string image;

    rv32i_cpu cpu (.*);
    data_mem memory (.*);
    assign instr_code = rom[instr_addr[31:2]];
    always #5 clk = ~clk;

    initial begin
        if (!$value$plusargs("IMAGE=%s", image)) $fatal(1, "Missing IMAGE");
        if (!$value$plusargs("WORDS=%d", words)) $fatal(1, "Missing WORDS");
        if (words < 1 || words > 512) $fatal(1, "Invalid ROM length");
        legacy_mode = $test$plusargs("LEGACY");
        result_base = legacy_mode ? 53 : 4;
        result_count = legacy_mode ? 6 : 5;
        terminal_pc = legacy_mode ? 116 : 8;
        if (legacy_mode) begin
            expected[0] = 0; expected[1] = 1; expected[2] = 3;
            expected[3] = 5; expected[4] = 7; expected[5] = 9;
        end else begin
            expected[0] = 1; expected[1] = 3; expected[2] = 5;
            expected[3] = 7; expected[4] = 9;
        end
        for (int i = 0; i < 512; i++) rom[i] = 32'h00000013;
        $readmemh(image, rom, 0, words - 1);
        for (int i = 0; i < 64; i++) memory.data_ram[i] = 0;
        // Avoid racing the register-file's original initial block.
        #1;
        for (int i = 1; i < 32; i++) cpu.U_DATA_PATH.U_REG_FILE.register_file[i] = 0;
        repeat (2) @(negedge clk);
        rst = 0;

        for (cycles = 0; cycles < 5000; cycles++) begin
            @(negedge clk);
            if ($isunknown(instr_addr) || instr_addr[1:0] != 0 ||
                instr_addr >= words * 4) $fatal(1, "Invalid PC: %h", instr_addr);
            if (dwe && ($isunknown(daddr) || daddr >= 256 || daddr[1:0] != 0))
                $fatal(1, "Invalid store address: %h", daddr);
            if (instr_code[6:0] == 7'b0000011 &&
                ($isunknown(daddr) || daddr >= 256 || daddr[1:0] != 0))
                $fatal(1, "Invalid load address: %h", daddr);
            if (instr_addr == terminal_pc) begin
                for (int i = 0; i < result_count; i++) begin
                    if (memory.data_ram[result_base + i] !== expected[i])
                        $fatal(1, "Result[%0d]: got %h expected %0d", i,
                               memory.data_ram[result_base + i], expected[i]);
                end
                if (legacy_mode && memory.data_ram[59] !== 32'h12345678)
                    $fatal(1, "Original completion marker missing");
                $display("PASS sort_reproduction: legacy=%0d cycles=%0d values=%0d",
                         legacy_mode, cycles + 1, result_count);
                $finish;
            end
        end
        $fatal(1, "Sort program timed out");
    end
endmodule
