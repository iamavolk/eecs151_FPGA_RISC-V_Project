module control_decode(
    input [31:0] instr,
    input BrEq, BrLt,

    output [5:0] ROMIn
);

reg [5:0] ROMIn;

wire opcode = instr[6:0];
wire func3 = instr[14:12];
wire func7 = instr[31:25];

always @(*) begin
    case (opcode)
	OPC_ARI_RTYPE: begin
	    case (func3)
	        FNC_ADD_SUB:
                    if (func7 == FNC7_0) ROMIn = 6'd0;  // add
                    else if (func7 == FNC7_1) ROMIn= 6'd1;   // sub
                FNC_SLL:
		    ROMIn = 6'd2;
                FNC_SLT:
		    ROMIn = 6'd3;
                FNC_SLTU:
		    ROMIn = 6'd4;
                FNC_XOR:
                FNC_OR:
                FNC_AND:
                FNC_SRL_SRA:
            endcase
        end
        OPC_LUI:
        OPC_AUIPC:
        OPC_JAL:
        OPC_JALR:
        OPC_BRANCH:
        OPC_STORE:
        OPC_LOAD:

        OPC_ARI_ITYPE:

    endcase
end


endmodule
