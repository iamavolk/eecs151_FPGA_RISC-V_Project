module control_unit(
    input [5:0] ROMIn,
    output RegWEn,
    output [2:0] ImmSel,
    output BrLUn, // used for load unsigned and branch unsigned
    output ASel,
    output BSel,
    output [3:0] ALUSel,
    output MemRW,
    output [1:0] WBSel,
    output [1:0] PCSel
);
    reg [15:0] hex;

    always @(*) begin
        case (ROMIn)
            6'd0: 16'h1001;
	    6'd1: 16'h1601;
	    6'd2: 16'h1081;
	    6'd3: 16'h1101;
	    6'd4:
	    6'd5:
	    6'd6:
	    6'd7:
	    6'd8:
	    6'd9:
	    6'd10:
	    6'd11:
        endcase
    end
endmodule
