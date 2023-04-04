module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);
    
    wire [9:0] tx_shift_d, tx_shift_q;
    wire tx_shift_ce;

    wire bit_counter_rst, bit_counter_ce;
    wire [3:0] bit_counter_value, bit_counter_value_next;

    wire clock_counter_rst, clock_counter_ce;
    wire [CLOCK_COUNTER_WIDTH-1:0] clock_counter_value;

    wire symbol_edge, done;

    REGISTER_R_CE #(.N(10), .INIT(10'hFFF)) tx_shift (
        .d(tx_shift_d),
        .q(tx_shift_q),
        .ce(tx_shift_ce),
        .rst(rst),
        .clk(clk)
    );

    REGISTER_R_CE #(.N(4), .INIT(4'd10)) bit_counter (
    .q(bit_counter_value),
    .d(bit_counter_value_next),
    .ce(bit_counter_ce),
    .rst(bit_counter_rst),
    .clk(clk)
    );

    REGISTER_R_CE #(.N(CLOCK_COUNTER_WIDTH), .INIT(0)) clock_counter (
    .q(clock_counter_value),
    .d(clock_counter_value + 1),
    .ce(clock_counter_ce),
    .rst(clock_counter_rst),
    .clk(clk)
    );

    wire start;
    REGISTER_R_CE #(.N(1), .INIT(0)) start_reg (
    .q(start),
    .d(1'b1),
    .ce(bit_counter_value == 0),
    .rst(done),
    .clk(clk)
    );

    wire data_in_fire = data_in_ready && data_in_valid;

    assign tx_shift_d = {1'b1, data_in, 1'b0};
    assign tx_shift_ce = data_in_fire;

    assign bit_counter_value_next = data_in_fire ? 4'd0 : (bit_counter_value == 4'd10 ? bit_counter_value : bit_counter_value + 1);
    assign bit_counter_rst = reset;
    assign bit_counter_ce = symbol_edge || data_in_fire;

    assign clock_counter_rst = symbol_edge || reset || done;
    assign clock_counter_ce = start;
    
    assign symbol_edge = (clock_counter_value == (SYMBOL_EDGE_TIME - 1));
    assign done = (bit_counter_value == 10) && symbol_edge;

    assign serial_out = bit_counter_value > 9 ? 1'b1: tx_shift_q[bit_counter_value];
    assign data_in_ready = (bit_counter_value == 10);
endmodule
