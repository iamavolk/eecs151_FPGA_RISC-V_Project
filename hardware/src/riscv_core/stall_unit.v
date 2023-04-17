`include "opcode.vh"
module stall_unit(
    input [4:0] rd_X,
    input [4:0] rs1_ID,
    input [4:0] rs2_ID,
    input [6:0] opcode,
    output stall
);
    
    assign stall = 
        ((opcode == `OPC_LOAD)
        && ((rd_X == rs1_ID)
        || (rd_X == rs2_ID))) ? 1'b1 : 1'b0;
     
endmodule
