module mem_wb_select #(
    parameter WIDTH = 32
)
(
    input mem_write,
    input [WIDTH-1:0] instr,
    input [WIDTH-1:0] data_in,
    input [3:0] addr_alu_res,
    input [1:0] offset,
    output [3:0] dmem_wea_mask,
    output [3:0] imem_wea_mask,
    output [WIDTH-1:0] data_out
);
    
    wire [1:0] func3_2ls_bit = instr[13:12];
    reg [3:0] mask;
    reg [WIDTH-1:0] data_out_reg;

    always @(*) begin
        case (func3_2ls_bit)
            2'b00: begin
                mask = 4'b0001 << offset;
                data_out_reg = data_in << (8 * offset);
            end

            2'b01: begin
                mask = 4'b0011 << offset;
                data_out_reg = data_in << (8 * offset);
            end
            2'b10: begin
                mask = 4'b1111;
                data_out_reg = data_in;
            end
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

    assign data_out = data_out_reg;

endmodule
