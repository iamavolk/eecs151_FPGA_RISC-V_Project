module control_decode(
    input [31:0] instr,
    output [5:0] ROMIn
);

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
                    if (func2 == FNC2_ADD) ROMIn = 6'd0;  	// add
                    else if (func2 == FNC2_SUB) ROMIn= 6'd1;	// sub
                FNC_SLL: ROMIn = 6'd2;				// sll
                FNC_SLT: ROMIn = 6'd3;				// slt
                FNC_SLTU: ROMIn = 6'd4;				// sltu
                FNC_XOR: ROMIn = 6'd5;				// xor
                FNC_SRL_SRA:
		    if (func2 == FCN2_SRL) ROMIn = 6'd6;	// srl
		    else if (func2 == FNC2_SRA) ROMIn = 6'd7;	// sra
		FCN_OR: ROMIn = 6'd8;				// or
		FCN_AND: ROMIn = 6'd9;				// and
            endcase
        end
	OPC_LOAD: begin
	    case (func3)
		FCN_LB: ROMIn = 6'd10;				// lb
		FCN_LH: ROMIn = 6'd11;				// lh
		FCN_LW: ROMIn = 6'd12;				// lw
		FCN_LBU: ROMIn = 6'd13;				// lbu
		FCN_LHU: ROMIn = 6'd14;				// lhu
	    endcase
	end
	OPC_ARI_ITYPE: begin
            case (func3)
                FNC_ADD_SUB: ROMIn = 6'd15;         		// addi
                FNC_SLL: ROMIn = 6'd16;                         // slli
                FNC_SLT: ROMIn = 6'd17;                         // slti
                FNC_SLTU: ROMIn = 6'd18;                        // sltiu
                FNC_XOR: ROMIn = 6'd19;                         // xori
                FNC_SRL_SRA:
                    if (func2 == FCN2_SRL) ROMIn = 6'd20;       // srli
                    else if (func2 == FNC2_SRA) ROMIn = 6'd21;  // srai
                FCN_OR: ROMIn = 6'd22;                          // ori
                FCN_AND: ROMIn = 6'd23;                         // andi
	    endcase
	end
	OPC_STORE: begin
	    case (func3)
		FCN_SB: ROMIn = 6'd24;				// sb
		FCN_SH: ROMIn = 6'd25;				// sh
		FCN_SW: ROMIn = 6'd26;				// sw
	    endcase
	end
	OPC_BRANCH: begin
	    case (func3)
		FCN_BEQ: ROMIn = 6'd27;				// beq
		FCN_BNE: ROMIn = 6'd28;				// bne
		FCN_BLT: ROMIn = 6'd29;				// blt
		FCN_BGE: ROMIn = 6'd30;				// bge
		FCN_BLTU: ROMIn = 6'd31;			// bltu
		FCN_BGEU: ROMIn = 6'd32;			// bgeu
	    endcase
	end
	OPC_AUIPC: ROMIn = 6'd33;				// auipc
        OPC_LUI: ROMIn = 6'd34;					// lue
        OPC_JAL: ROMIn = 6'd35;					// jal
        OPC_JALR: ROMIn = 6'd36;				// jalr
	default: ROMIn = 6'bx;					// undefined
    endcase
end


endmodule
