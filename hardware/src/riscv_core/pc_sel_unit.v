module pc_sel_unit(
    input [15:0] instr_hex,
    input BrEq, BrLt, is_jal_id,
    output [1:0] PCSel
);
    localparam HBEQ = 16'h0064;
    localparam HBNE = 16'h4064;
    localparam HBLT = 16'h8064;
    localparam HBGE = 16'hC064;
    localparam HBLTU = 16'h0074;
    localparam HBGEU = 16'h4074;
    localparam HJALR = 16'h2041;

    wire br_jalr;
    assign br_jalr =
	(instr_hex == HBEQ && BrEq) ||
	(instr_hex == HBNE && ~BrEq) ||
	((instr_hex == HBLT || instr_hex == HBLTU) && BrLt) ||
	((instr_hex == HBGE || instr_hex == HBGEU) && ~BrLt) ||
	(instr_hex == HJALR);

    //assign PCSel =
	// (is_jal_id) ? 2'b01 :
	// (br_jalr ? 2'b10 : 2'b00);

    assign PCSel = (br_jalr) ? 2'b10 : 2'b00;
endmodule
