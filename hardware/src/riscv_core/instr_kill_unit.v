module instr_kill_unit(
    input [1:0] pc_sel_x,
    input [1:0] pc_sel_wb,
    output instr_kill_res
);
    assign instr_kill_res = ((pc_sel_x == 2'b01) || (pc_sel_x == 2'b10) || (pc_sel_wb == 2'b10)) ? 1'b1 : 1'b0;

endmodule
