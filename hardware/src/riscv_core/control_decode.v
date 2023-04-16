`include "instr.vh"
`include "opcode.vh"
module control_decode(
    input [31:0] instr,
    output [5:0] ROMIn
);

reg [5:0] ROMIn_res;

wire [6:0] opcode = instr[6:0];
wire [2:0] func3 = instr[14:12];
//wire func7 = instr[31:25];
wire func2 = instr[30];

always @(*) begin
    case (opcode)
	`OPC_ARI_RTYPE: begin
	    case (func3)
	        `FNC_ADD_SUB:
                    if (func2 == `FNC2_ADD) ROMIn_res = `ADD;
                    else if (func2 == `FNC2_SUB) ROMIn_res = `SUB;
                `FNC_SLL: ROMIn_res = `SLL;
                `FNC_SLT: ROMIn_res = `SLT;
                `FNC_SLTU: ROMIn_res = `SLTU;
                `FNC_XOR: ROMIn_res = `XOR;
                `FNC_SRL_SRA:
		   if (func2 == `FNC2_SRL) ROMIn_res = `SRL;
		    else if (func2 == `FNC2_SRA) ROMIn_res = `SRA;
		`FNC_OR: ROMIn_res = `OR;
		`FNC_AND: ROMIn_res = `AND;
		default: ROMIn_res = 6'bxxxxxx;
            endcase
        end
	`OPC_LOAD: begin
	    case (func3)
		`FNC_LB: ROMIn_res = `LB;
		`FNC_LH: ROMIn_res = `LH;
		`FNC_LW: ROMIn_res = `LW;
		`FNC_LBU: ROMIn_res = `LBU;
		`FNC_LHU: ROMIn_res = `LHU;
		default: ROMIn_res = 6'bxxxxxx;
	    endcase
	end
	`OPC_ARI_ITYPE: begin
            case (func3)
                `FNC_ADD_SUB: ROMIn_res = `ADDI;
                `FNC_SLL: ROMIn_res = `SLLI;
                `FNC_SLT: ROMIn_res = `SLTI;
                `FNC_SLTU: ROMIn_res = `SLTIU;
                `FNC_XOR: ROMIn_res = `XORI;
                `FNC_SRL_SRA:
                    if (func2 == `FNC2_SRL) ROMIn_res = `SRLI;
                    else if (func2 == `FNC2_SRA) ROMIn_res = `SRAI;
                `FNC_OR: ROMIn_res = `ORI;
                `FNC_AND: ROMIn_res = `ANDI;
		default: ROMIn_res = 6'bxxxxxx;
	    endcase
	end
	`OPC_STORE: begin
	    case (func3)
		`FNC_SB: ROMIn_res = `SB;
		`FNC_SH: ROMIn_res = `SH;
		`FNC_SW: ROMIn_res = `SW;
                default: ROMIn_res = 6'bxxxxxx;
	    endcase
	end
	`OPC_BRANCH: begin
	    case (func3)
		`FNC_BEQ: ROMIn_res = `BEQ;
		`FNC_BNE: ROMIn_res = `BNE;
		`FNC_BLT: ROMIn_res = `BLT;
		`FNC_BGE: ROMIn_res = `BGE;
		`FNC_BLTU: ROMIn_res = `BLTU;
		`FNC_BGEU: ROMIn_res = `BGEU;
                default: ROMIn_res = 6'bxxxxxx;
	    endcase
	end
	`OPC_AUIPC: ROMIn_res = `AUIPC;
        `OPC_LUI: ROMIn_res = `LUI;
        `OPC_JAL: ROMIn_res = `JAL;
        `OPC_JALR: ROMIn_res = `JALR;
	//default: ROMIn_res = 6'bxxxxxx;	// was here before I introduced CLEAR_NOP 
	default: ROMIn_res = `NOPE;	// undefined
    endcase
end

assign ROMIn = ROMIn_res;

endmodule
