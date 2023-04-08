module control_decode(
    input [31:0] instr,
    output [5:0] ROMIn
);
`include opcode.vh
`include instr.vh

reg [5:0] ROMIn;

wire opcode = instr[6:0];
wire func3 = instr[14:12];
//wire func7 = instr[31:25];
wire func2 = instr[30];

always @(*) begin
    case (opcode)
	OPC_ARI_RTYPE: begin
	    case (func3)
	        FNC_ADD_SUB:
                    if (func2 == FNC2_ADD) ROMIn = ADD;
                    else if (func2 == FNC2_SUB) ROMIn= SUB;
                FNC_SLL: ROMIn = SLL;
                FNC_SLT: ROMIn = SLT;
                FNC_SLTU: ROMIn = SLTU;
                FNC_XOR: ROMIn = XOR;
                FNC_SRL_SRA:
		   if (func2 == FCN2_SRL) ROMIn = SRL;
		    else if (func2 == FNC2_SRA) ROMIn = SRA;
		FCN_OR: ROMIn = OR;
		FCN_AND: ROMIn = AND;
            endcase
        end
	OPC_LOAD: begin
	    case (func3)
		FCN_LB: ROMIn = LB;
		FCN_LH: ROMIn = LH;
		FCN_LW: ROMIn = LW;
		FCN_LBU: ROMIn = LBU;
		FCN_LHU: ROMIn = LHU;
	    endcase
	end
	OPC_ARI_ITYPE: begin
            case (func3)
                FNC_ADD_SUB: ROMIn = ADDI;
                FNC_SLL: ROMIn = SLLI;
                FNC_SLT: ROMIn = SLTI;
                FNC_SLTU: ROMIn = SLTIU;
                FNC_XOR: ROMIn = XORI;
                FNC_SRL_SRA:
                    if (func2 == FCN2_SRL) ROMIn = SRLI;
                    else if (func2 == FNC2_SRA) ROMIn = SRAI;
                FCN_OR: ROMIn = ORI;
                FCN_AND: ROMIn = ANDI;
	    endcase
	end
	OPC_STORE: begin
	    case (func3)
		FCN_SB: ROMIn = SB;
		FCN_SH: ROMIn = SH;
		FCN_SW: ROMIn = SW;
	    endcase
	end
	OPC_BRANCH: begin
	    case (func3)
		FCN_BEQ: ROMIn = BEQ;
		FCN_BNE: ROMIn = BNE;
		FCN_BLT: ROMIn = BLT;
		FCN_BGE: ROMIn = BGE;
		FCN_BLTU: ROMIn = BLTU;
		FCN_BGEU: ROMIn = BGEU;
	    endcase
	end
	OPC_AUIPC: ROMIn = AUIPC;
        OPC_LUI: ROMIn = LUI;
        OPC_JAL: ROMIn = JAL;
        OPC_JALR: ROMIn = JALR;
	default: ROMIn = 6'bx;	// undefined
    endcase
end

endmodule
