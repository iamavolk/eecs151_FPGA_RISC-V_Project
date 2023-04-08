module pc_sel_unit(
    input [5:0] dec_instr_code,
    input BrEq, BrLt, is_jal_id,
    output PCSel
);
    `include "instr.vh"
    wire br_jalr;
    assign br_jalr =
	(dec_instr_code == BEQ && BrEq) ||
	(dec_instr_code == BNE && ~BrEq) ||
	((dec_instr_code == BLT || dec_instr_code == BLTU) && BrLt) ||
	((dec_instr_code == BGE || dec_instr_code == BGEU) && ~BrLt) ||
	(dec_instr_code == JALR);

   assign PCSel =
	(is_jal_id) ? 2'b01 :
	(br_jalr ? 2'b10 : 2'b00);

endmodule
