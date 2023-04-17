`timescale 1ns/1ns
`include "mem_path.vh"

module asm_tb_custom();
    reg clk, rst;
    parameter CPU_CLOCK_PERIOD = 20;
    parameter CPU_CLOCK_FREQ   = 1_000_000_000 / CPU_CLOCK_PERIOD;

    initial clk = 0;
    always #(CPU_CLOCK_PERIOD/2) clk = ~ clk;

    reg bp_enable = 1'b0;

    cpu # (
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ),
        .RESET_PC(32'h1000_0000)
    ) cpu (
        .clk(clk),
        .rst(rst),
        .bp_enable(bp_enable),
        .serial_in(1'b1),
        .serial_out()
    );


    task check_reg_val;
	input [4:0] reg_number;
	input [31:0] expected_value;
	input [10:0] test_num;

	reg [31:0] actual_value;
	fork: wait_or_timeout
	    begin
		#10000; // 10ms
		$display("Timeout! Expected: %d. Actual: %d.", expected_value, actual_value);
		disable wait_or_timeout;
	    end
	    begin
		actual_value = `RF_PATH.mem[reg_number];
		while (actual_value !== expected_value) begin
		    @(posedge clk)
		    actual_value = `RF_PATH.mem[reg_number];
		end
		$display("PASS - test %d, got: %d for reg %d", test_num, expected_value, reg_number);
		disable wait_or_timeout;
	    end
	join
    endtask



 initial begin
    `ifndef IVERILOG
        $vcdpluson;
        $vcdplusmemon;
    `endif
    `ifdef IVERILOG
        $dumpfile("asm_tb.fst");
        $dumpvars(0, asm_tb);
    `endif
    #1;
    $readmemh("../../software/asm_custom/asm.hex", `IMEM_PATH.mem, 0, 16384-1);
    $readmemh("../../software/asm_custom/asm.hex", `DMEM_PATH.mem, 0, 16384-1);

    // Reset the CPU
    rst = 1;
    repeat (10) @(posedge clk);
    @(negedge clk);
    rst = 0;

    // test
    check_reg_val(0, 32'd0, 1);

    $finish();
  end


endmodule
