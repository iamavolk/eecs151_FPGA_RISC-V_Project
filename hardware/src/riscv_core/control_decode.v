`include "instr.vh"
`include "opcode.vh"
module control_decode(
    input [31:0] instr,
    output [5:0] ROMIn
);

reg [5:0] ROMIn;

wire [6:0] opcode = instr[6:0];
wire [2:0] func3 = instr[14:12];
//wire func7 = instr[31:25];
wire func2 = instr[30];

always @(*) begin
    case (opcode)
	`OPC_ARI_RTYPE: begin
	    case (func3)
	        `FNC_ADD_SUB:
                    if (func2 == `FNC2_ADD) ROMIn = `ADD;
                    else if (func2 == `FNC2_SUB) ROMIn= `SUB;
                `FNC_SLL: ROMIn = `SLL;
                `FNC_SLT: ROMIn = `SLT;
                `FNC_SLTU: ROMIn = `SLTU;
                `FNC_XOR: ROMIn = `XOR;
                `FNC_SRL_SRA:
		   if (func2 == `FNC2_SRL) ROMIn = `SRL;
		    else if (func2 == `FNC2_SRA) ROMIn = `SRA;
		`FNC_OR: ROMIn = `OR;
		`FNC_AND: ROMIn = `AND;
		default: ROMIn = 6'bxxxxxx;
            endcase
        end
	`OPC_LOAD: begin
	    case (func3)
		`FNC_LB: ROMIn = `LB;
		`FNC_LH: ROMIn = `LH;
		`FNC_LW: ROMIn = `LW;
		`FNC_LBU: ROMIn = `LBU;
		`FNC_LHU: ROMIn = `LHU;
		default: ROMIn = 6'bxxxxxx;
	    endcase
	end
	`OPC_ARI_ITYPE: begin
            case (func3)
                `FNC_ADD_SUB: ROMIn = `ADDI;
                `FNC_SLL: ROMIn = `SLLI;
                `FNC_SLT: ROMIn = `SLTI;
                `FNC_SLTU: ROMIn = `SLTIU;
                `FNC_XOR: ROMIn = `XORI;
                `FNC_SRL_SRA:
                    if (func2 == `FNC2_SRL) ROMIn = `SRLI;
                    else if (func2 == `FNC2_SRA) ROMIn = `SRAI;
                `FNC_OR: ROMIn = `ORI;
                `FNC_AND: ROMIn = `ANDI;
		default: ROMIn = 6'bxxxxxx;
	    endcase
	end
	`OPC_STORE: begin
	    case (func3)
		`FNC_SB: ROMIn = `SB;
		`FNC_SH: ROMIn = `SH;
		`FNC_SW: ROMIn = `SW;
                default: ROMIn = 6'bxxxxxx;
	    endcase
	end
	`OPC_BRANCH: begin
	    case (func3)
		`FNC_BEQ: ROMIn = `BEQ;
		`FNC_BNE: ROMIn = `BNE;
		`FNC_BLT: ROMIn = `BLT;
		`FNC_BGE: ROMIn = `BGE;
		`FNC_BLTU: ROMIn = `BLTU;
		`FNC_BGEU: ROMIn = `BGEU;
                default: ROMIn = 6'bxxxxxx;
	    endcase
	end
	`OPC_AUIPC: ROMIn = `AUIPC;
        `OPC_LUI: ROMIn = `LUI;
        `OPC_JAL: ROMIn = `JAL;
        `OPC_JALR: ROMIn = `JALR;
	default: ROMIn = 6'bxxxxxx;	// undefined
    endcase
end

endmodule
