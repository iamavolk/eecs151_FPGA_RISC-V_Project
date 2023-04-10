module control_unit(
    input [5:0] dec_instr_code,
    output [15:0] hex_instr_code
);
    localparam DATA_WIDTH = 16;
    localparam ADDR_WIDTH = 6;
    ASYNC_ROM #(.DWIDTH(DATA_WIDTH), .AWIDTH(ADDR_WIDTH), .MIF_HEX("../../hardware/src/riscv_core/ROM.mif")) 
    async_rom (.addr(dec_instr_code),
               .q(hex_instr_code));
endmodule
