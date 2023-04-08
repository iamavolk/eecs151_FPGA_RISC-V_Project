module control_unit(
    input [15:0] hex,
    input [5:0] instr_code,

    output RegWEn,
    output [2:0] ImmSel,
    output BrLUn, // used for load unsigned and branch unsigned
    output ASel,
    output BSel,
    output [3:0] ALUSel,
    output MemRW,
    output [1:0] WBSel,
    output [1:0] PCSel
);
    assign RegWEn = hex[0];
    assign ImmSel = hex[3:1];
    assign BrLUn = hex[4];
    assign ASel = hex[5];
    assign BSel = hex[6];
    assign ALUSel = hex[10:7];
    assign MemRW = hex[11];
    assign WBSel = hex[13:12];


endmodule
