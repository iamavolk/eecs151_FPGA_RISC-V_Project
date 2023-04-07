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
                    if (func7 == FNC7_0) ROMIn = 6'd0;  	// add
                    else if (func7 == FNC7_1) ROMIn= 6'd1;	// sub
                FNC_SLL: ROMIn = 6'd2;				// sll
                FNC_SLT: ROMIn = 6'd3;				// slt
                FNC_SLTU: ROMIn = 6'd4;				// sltu
                FNC_XOR: ROMIn = 6'd5;				// xor
                FNC_SRL_SRA:
		    if (func7 == FCN7_0) ROMIn = 6'd6;		// srl
		    else if (func7 == FNC7_1) ROMIn = 6'd7;	// sra
		FCN_OR: ROMIn = 6'd8;				// or
		FCN_AND: ROMIn = 6'd9;				// and
            endcase
        end
	OPC_LOAD: begin
	    case (func3)
		FCN_LB: ROMIn = 6'd10;		// lb
		FCN_LH: ROMIn = 6'd11;		// lh
		FCN_LW: ROMIn = 6'd12;		// lw
		FCN_LBU: ROMIn = 6'd13;		// lbu
		FCN_LHU: ROMIn = 6'd14;		// lhu
	    endcase
	end
	OPC_ARI_ITYPE: begin
            case (func3)
                FNC_ADD_SUB: ROMIn = 6'd15;         		// addi
                FNC_SLL: ROMIn = 6'd16;                         // slli
                FNC_SLT: ROMIn = 6'd17;                         // slti
                FNC_SLTU: ROMIn = 6'd18;                        // sltiu
                FNC_XOR: ROMIn = 6'd19;                          // xori
                FNC_SRL_SRA:
                    if (func7 == FCN7_0) ROMIn = 6'd20;         // srli
                    else if (func7 == FNC7_1) ROMIn = 6'd21;    // srai
                FCN_OR: ROMIn = 6'd22;                          // ori
                FCN_AND: ROMIn = 6'd23;                         // andi
	    endcase
	end
        OPC_LUI:
        OPC_AUIPC:
        OPC_JAL:
        OPC_JALR:
        OPC_BRANCH:
        OPC_STORE:


    endcase
end


endmodule
