module imm_generator #(
    parameter N = 32
)
(
    input [N-1:0] instr,
    input [1:0] imm_sel,

    output [N-1:0] imm
);
    //localparam SLTIU_OPCODE = 7'b0010011;
    localparam SLTIU_FUNC3 = 3'b011;
    // I* type params
    localparam SLLI_FUNC3 = 3'b001;
    localparam SRI_FUNC3 = 3'b101;
    wire [2:0] func3 = instr[14:12];

wire [N-1:0] s_type =
	{{N-12{instr[31]}},
	instr[31:25],
	instr[11:7]};

wire [11:0] i_type = instr[31:20];
wire [4:0] i_star_type = instr[24:20];

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
	(func3 == SLTIU_FUNC3)?
	{{N-12{1'b0}}, i_type} :
	(func3 == SLLI_FUNC3 || func3 == SRI_FUNC3 ?
	{{N-5{1'b0}}, i_star_type} :
	{{N-12{instr[31]}}, i_type});

mux4 imm_gen(.in0(i_type_ext),
        .in1(s_type),
        .in2(b_type),
        .in3(u_type),
        .sel(imm_sel),
        .out(imm)
);

endmodule
