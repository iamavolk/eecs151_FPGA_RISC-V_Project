module branch_comp #(
    parameter N = 32
)
(
    input [N-1:0] br_data0, br_data1,
    input BrUn,
    output BrEq, BrLt
);

reg BrLt;

wire b0 = br_data0[N-1];
wire b1 = br_data1[N-1];

always @(*) begin
    if (BrUn || ~(b0 || b1))        // unsigned or 2 positive 2's complement
        BrLt = br_data0 < br_data1;
    else if (b0 && b1)              // 2 negative 2's complement
        BrLt = br_data1 < br_data0;
    else if (b0)                    // br_data0 is negative
        BrLt = 1'b1;
    else if (b1)                    // br_data1 is negative
        BrLt = 1'b0;
end

assign BrEq = br_data0 == br_data1; // equal regardless of sign system

endmodule