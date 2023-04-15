module mem_load_mask #(
    parameter WIDTH = 32
) (
    input [1:0] addr,
    input [2:0] func3,
    input [WIDTH-1:0] mem_res,
    output [WIDTH-1:0] mem_masked_out
);
    localparam BYTE = 8;
    localparam HALF = 16;

    wire [WIDTH-1:0] byte_in;
    mux4 #(.N(WIDTH))
    b_mux (.in0(mem_res[7:0]),
           .in1(mem_res[15:8]),
           .in2(mem_res[23:16]),
           .in3(mem_res[31:24]),
           .sel(addr),
           .out(byte_in));

    wire [WIDTH-1:0] byte_res;
    wire byte_msb = byte_in[BYTE*(addr + 1) - 1];
    mux2 #(.N(WIDTH))
    byte_mux (.in1({24'b0, byte_in}), 
              .in0({{24{byte_msb}}, byte_in}),
              .sel(func3[2]),
              .out(byte_res)); 
    
    wire [WIDTH-1:0] half;
    mux2 #(.N(WIDTH))
    h_mux (.in0(mem_res[15:0]), 
           .in1(mem_res[31:16]),
           .sel(addr[1]),
           .out(half)); 

    wire [WIDTH-1:0] half_res;
    wire half_msb = half[HALF*(addr[1] + 1) - 1];
    mux2 #(.N(WIDTH))
    half_mux (.in1({16'b0, half}), 
              .in0({{16{half_msb}}, half}),
              .sel(func3[2]),
              .out(half_res)); 
    
    mux3 #(.N(WIDTH))
    res_mux (.in0(byte_res),
             .in1(half_res),
             .in2(mem_res),
             .sel(func3[1:0]),
             .out(mem_masked_out)); 
endmodule
