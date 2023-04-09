module imm_generator #(
    parameter N = 32
)
(
    input [N-1:0] instr,
    input [1:0] imm_sel,

    output [N-1:0] imm
);

wire [N-1:0] i_in = instr[21:10];
wire [N-1:0] b_in = instr[31:12];

wire [N-1:0] s_type =
	{{N-12{1'b0}},
	instr[31:25],
	instr[11:7]};

wire [N-1:0] i_type =
	{{N-12{1'b0}},
	instr[31:20]};

wire [N-1:0] u_type =
	instr[31:12] << 12;

wire [N-1:0] b_type =
	{{N-13{1'b0}},
	instr[31],
	instr[7],
	instr[30:25],
	instr[11:8],
	1'b0};

mux4 imm_gen(.in0(i_type),
        .in1(s_type),
        .in2(b_type),
        .in3(u_type),
        .sel(imm_sel),
        .out(imm)
);

endmodule
