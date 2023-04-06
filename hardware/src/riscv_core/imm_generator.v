module imm_generator #(
    parameter N = 32
)
(
    input [N-1:0] instr,
    input [1:0] imm_sel,

    output [N-1:0] imm
);

wire [N-1:0] s_type = {instr[31:25], instr[11:7]};
wire [N-1:0] i_type = instr[21:10];
wire [N-1:0] u_type = instr[31:12] << 12;
wire [N-1:0] j_type = instr[31:12];


mux4 imm_gen(.in0(s_type),
        .in1(i_type),
        .in2(u_type),
        .in3(j_type),
        .sel(imm_sel),
        .out(imm)
);

endmodule