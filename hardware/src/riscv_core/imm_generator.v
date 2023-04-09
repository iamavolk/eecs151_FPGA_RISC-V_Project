module imm_generator #(
    parameter N = 32
)
(
    input [N-1:0] instr,
    input [1:0] imm_sel,

    output [N-1:0] imm
);
    localparam SLTIU_OPCODE = 7'b0010011;
    localparam SLTIU_FUNC3 = 3'b011;

wire [N-1:0] s_type =
	{{N-12{instr[31]}},
	instr[31:25],
	instr[11:7]};

wire [11:0] i_type = instr[31:20];

wire [N-1:0] u_type =
	{instr[31:12], {12{1'b0}}};

wire [N-1:0] b_type =
	{{N-13{instr[31]}},
	instr[31],
	instr[7],
	instr[30:25],
	instr[11:8],
	1'b0};

wire [N-1:0] i_type_ext =
	instr[6:0] == SLTIU_OPCODE && instr[14:12] == SLTIU_FUNC3 ?
	{{N-12{1'b0}}, i_type} :
	{{N-12{instr[31]}}, i_type};

mux4 imm_gen(.in0(i_type_ext),
        .in1(s_type),
        .in2(b_type),
        .in3(u_type),
        .sel(imm_sel),
        .out(imm)
);

endmodule
