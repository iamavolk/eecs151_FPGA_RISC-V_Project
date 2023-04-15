module mem_wb_select #(
    parameter WIDTH = 32
)
(
    input mem_write,
    input [WIDTH-1:0] instr,
    input [3:0] addr_alu_res,
    output [3:0] dmem_wea_mask,
    output [3:0] imem_wea_mask
);
    
    wire [1:0] func3_2ls_bit = instr[13:12];
    reg [3:0] mask;

    always @(*) begin
        case (func3_2ls_bit)
            2'b00: mask = 4'b0001;
            2'b01: mask = 4'b0011;
            2'b10: mask = 4'b1111;
            default: mask = 4'b0000;
        endcase
    end

    assign dmem_wea_mask = (
        mem_write &&
        ((addr_alu_res == 4'b0000) ||             // TODO: change 4'b0000 to 4'b0001 for SPEC
        (addr_alu_res == 4'b0011))
    ) ? mask : 4'b0000;

    assign imem_wea_mask = (
        mem_write &&
        ((addr_alu_res == 4'b0010) ||
        (addr_alu_res == 4'b0011))
    ) ? mask : 4'b0000;

endmodule
