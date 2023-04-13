`timescale 1ns/1ns
`include "mem_path.vh"

module asm_tb();
  reg clk, rst;
  parameter CPU_CLOCK_PERIOD = 20;
  parameter CPU_CLOCK_FREQ   = 1_000_000_000 / CPU_CLOCK_PERIOD;

  initial clk = 0;
  always #(CPU_CLOCK_PERIOD/2) clk = ~clk;
  
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

  // A task to check if the value contained in a register equals an expected value
  task check_reg;
    input [4:0] reg_number;
    input [31:0] expected_value;
    input [10:0] test_num;
    if (expected_value !== `RF_PATH.mem[reg_number]) begin
      $display("FAIL - test %d, got: %d, expected: %d for reg %d",
               test_num, `RF_PATH.mem[reg_number], expected_value, reg_number);
      $finish();
    end
    else begin
      $display("PASS - test %d, got: %d for reg %d", test_num, expected_value, reg_number);
    end
  endtask

  // A task that runs the simulation until a register contains some value
  task wait_for_reg_to_equal;
    input [4:0] reg_number;
    input [31:0] expected_value;
    while (`RF_PATH.mem[reg_number] !== expected_value)
      @(posedge clk);
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
    $readmemh("../../software/asm/asm.hex", `IMEM_PATH.mem, 0, 16384-1);
    $readmemh("../../software/asm/asm.hex", `DMEM_PATH.mem, 0, 16384-1);

    // Reset the CPU
    rst = 1;
    repeat (10) @(posedge clk);             // Hold reset for 10 cycles
    @(negedge clk);
    rst = 0;

    // Your processor should begin executing the code in /software/asm/start.s

    wait_for_reg_to_equal(1, 32'd100);	// li x1 100
    check_reg(1, 32'd100, 1);

    wait_for_reg_to_equal(2, 32'd40);	// li x2 40
    check_reg(2, 32'd40, 2);

    wait_for_reg_to_equal(11, 32'd2);	// li x11 2
    check_reg(11, 32'd2, 3);

    wait_for_reg_to_equal(12, 32'd1);	// li x12 1
    check_reg(12, 32'd1, 4);

    wait_for_reg_to_equal(3, 32'd60);	// sub x3 x1 x2
    check_reg(3, 32'd60, 5);

    wait_for_reg_to_equal(4, 32'd140);	// add x4 x1 x1
    check_reg(4, 32'd140, 6);

    wait_for_reg_to_equal(5, 32'd4);	// sll x5 x11 x12
    check_reg(5, 32'd4, 7);

    wait_for_reg_to_equal(6, 32'd1);	// srl x6 x1 x1
    check_reg(6, 32'd1, 8);

    wait_for_reg_to_equal(7, 32'd0);	// slt x7 x1 x1
    check_reg(7, 32'd0, 9);

    wait_for_reg_to_equal(8, 32'd1);    // slt x8 x2 x1
    check_reg(8, 32'd1, 10);

    wait_for_reg_to_equal(10, 32'hFFFFFFF6);	// li x10 -10
    check_reg(10, 32'hFFFFFFF6, 11);

    wait_for_reg_to_equal(3, 32'b100000);	// and x3 x1 x2
    check_reg(3, 32'b100000, 12);

    wait_for_reg_to_equal(4, 32'd108);		// or x4 x1 x2
    check_reg(4, 32'd108, 13);

    wait_for_reg_to_equal(5, 32'b1001100);	// xor x5 x1 x2
    check_reg(5, 32'b1001100, 14);

    wait_for_reg_to_equal(6, 32'b1);      // sltu x6 x2 x10
    check_reg(6, 32'b1, 15);

    wait_for_reg_to_equal(7, 32'b1);      // slt x7 x10 x2
    check_reg(7, 32'b1, 16);

    wait_for_reg_to_equal(8, 32'hFFFFFFFD);	// srai x8 x10 2
    check_reg(8, 32'hFFFFFFFD, 17);

    wait_for_reg_to_equal(9, 32'h3FFFFFFD);     // srli x9 x10 2
    check_reg(9, 32'h3FFFFFFD, 18);

    wait_for_reg_to_equal(13, 32'b1);		// sltiu x13 x11 -20
    check_reg(13, 32'b1, 19);

    wait_for_reg_to_equal(14, 32'b1);     	// sltiu x14 x11 20
    check_reg(14, 32'b1, 20);

    wait_for_reg_to_equal(15, 32'b0);     	// sltiu x15 x11 1
    check_reg(15, 32'b0, 21);

    wait_for_reg_to_equal(0, 32'b0);           // li x0 1
    check_reg(0, 32'b0, 22);

    wait_for_reg_to_equal(0, 32'b0);           // add x0 x0 1
    check_reg(0, 32'b0, 23);

    // Test BEQ
    //wait_for_reg_to_equal(20, 32'd2);       // Run the simulation until the flag is set to 2
    //check_reg(1, 32'd500, 2);               // Verify that x1 contains 500
    //check_reg(2, 32'd100, 3);               // Verify that x2 contains 100
    $display("ALL ASSEMBLY TESTS PASSED!");
    $finish();
  end

  initial begin
    repeat (100) @(posedge clk);
    $display("Failed: timing out");
    $fatal();
  end
endmodule
