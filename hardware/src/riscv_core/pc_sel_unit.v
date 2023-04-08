module pc_sel_unit(
    input [15:0] instr_hex,
    input BrEq, BrLt, is_jal_id,
    output [1:0] PCSel
);
    `include "instr.vh"
    localparam HBEQ = 16'h0064;
    localparam HBNE = 16'h4064;
    localparam HBLT = 16'h8064;
    localparam HBGE = 16'hC064;
    localparam HBLTU = 16'h0074;
    localparam HBGEU = 16'h4074;

    wire br_jalr;
    assign br_jalr =
	(dec_instr_code == HBEQ && BrEq) ||
	(dec_instr_code == HBNE && ~BrEq) ||
	((dec_instr_code == HBLT || dec_instr_code == HBLTU) && BrLt) ||
	((dec_instr_code == HBGE || dec_instr_code == HBGEU) && ~BrLt) ||
	(dec_instr_code == JALR);

   assign PCSel =
	(is_jal_id) ? 2'b01 :
	(br_jalr ? 2'b10 : 2'b00);

endmodule
