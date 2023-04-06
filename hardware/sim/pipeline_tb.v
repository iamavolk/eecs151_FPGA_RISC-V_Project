`timescale 1ns/1ns

`define CLK_PERIOD 8

module pipeline_tb();
    reg [31:0] din_rd;
    reg [4:0] addr_rd;

    reg [31:0] dout_rs1;
    reg [31:0] dout_rs1_p;
    reg [4:0] addr_in_rs1;

    reg [31:0] dout_rs2;
    reg [31:0] dout_rs2_p;
    reg [4:0] addr_in_rs2;

    reg [31:0] alu_res;
    wire [31:0] alu_res_p;
    reg [3:0] alu_op;
    reg reg_file_we = 0;
    reg pipeline_rs1_en = 0;
    reg pipeline_rs2_en = 0;
    reg pipeline_alu_out_en = 0;

    reg clk = 0;

    always #(`CLK_PERIOD/2) clk <= ~clk;

    ASYNC_RAM_1W2R #(
        .DWIDTH(32), 
        .AWIDTH(5),
        .MIF_HEX("test.mif")
    ) reg_file (
        .d0(din_rd),
        .addr0(addr_rd), 
        .we0(reg_file_we),
        .q1(dout_rs1),
        .addr1(addr_in_rs1), 
        .q2(dout_rs2),
        .addr2(addr_in_rs2), 
        .clk(clk)
    );


    alu #(.N(32)) ALU_unit (.A(dout_rs1), .B(dout_rs2), .ALUSel(alu_op), .ALURes(alu_res));
    REGISTER_CE #(.N(32)) pipeline_rs1 (.d(dout_rs1), .q(dout_rs1_p), .ce(pipeline_rs1_en), .clk(clk));
    REGISTER_CE #(.N(32)) pipeline_rs2 (.d(dout_rs2), .q(dout_rs2_p), .ce(pipeline_rs2_en), .clk(clk));
    REGISTER_CE #(.N(32)) pipeline_alu_out (.q(alu_res_p), .d(alu_res), .ce(pipeline_alu_out_en), .clk(clk));

    //assign dout_rs1 = dout_rs1_p;
    //assign dout_rs2 = dout_rs2_p;


    initial begin
        `ifndef IVERILOG
            $dumpfile("pipeline_tb.fst");
            $dumpvars(0, pipeline_tb);
        `endif
        `ifndef IVERILOG
            $vcdpluson;
            $vcdplusmemon;
        `endif
         alu_op = 4'b1111;
         repeat (10) @(posedge clk);

         din_rd = 5;
         addr_rd = 0;
         reg_file_we = 1;

         @(posedge clk);

         reg_file_we = 0; 

         @(posedge clk);

         din_rd = 3;
         addr_rd = 3;
         reg_file_we = 1;

         @(posedge clk);

         reg_file_we = 0;

         @(posedge clk);
         
         addr_in_rs1 = 0;
         addr_in_rs2 = 3;
         pipeline_rs2_en = 1; 
         pipeline_rs1_en = 1;
            
         @(posedge clk); 

         pipeline_rs2_en = 0; 
         pipeline_rs1_en = 0;
         repeat (10) @(posedge clk);
        
        
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end
endmodule
