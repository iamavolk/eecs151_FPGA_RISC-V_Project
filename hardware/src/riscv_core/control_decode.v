module control_decode(
    input [31:0] instr,
    input BrEq, BrLt,

    output ROMIn
);

wire opcode = instr[6:0];
wire func3 = instr[14:12];
wire func7 = instr[31:25];

always @(*) begin
    case (opcode)
        OPC_LUI:
        OPC_AUIPC:
        OPC_JAL:
        OPC_JALR:
        OPC_BRANCH:
        OPC_STORE:
        OPC_LOAD:
        OPC_ARI_RTYPE:
        OPC_ARI_ITYPE:

    endcase
end


endmodule