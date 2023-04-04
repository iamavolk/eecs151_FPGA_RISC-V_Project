module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
    // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge
    // Feel free to use as many number of registers you like
    wire [WIDTH-1:0] out_q0;
    wire [WIDTH-1:0] out_q1;
    // Remove this line once you create your edge detector
    REGISTER #(WIDTH) r0 (.q(out_q0), .d(signal_in), .clk(clk));
    REGISTER #(WIDTH) r1 (.q(out_q1), .d(out_q0), .clk(clk));
    assign edge_detect_pulse = out_q0 & ~out_q1;

    //assign edge_detect_pulse = 0;
endmodule
