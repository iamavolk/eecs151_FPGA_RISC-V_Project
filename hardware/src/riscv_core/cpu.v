`include "instr.vh"
`include "opcode.vh"
module cpu #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter RESET_PC = 32'h4000_0000,
    parameter BAUD_RATE = 115200,
    parameter BIOS_MIF_HEX = ""
) (
    input clk,
    input rst,
    input bp_enable,
    input serial_in,
    output serial_out
);
    localparam X0_ADDR = 5'b00000;
    localparam DWIDTH = 32;
    localparam BEWIDTH = DWIDTH / 8;
    localparam CWIDTH = 16;
    localparam ROM_IDX_WIDTH = 6;
    localparam CTRL_KILL = 16'b0;
    localparam HJAL = 16'h2069;
    
    // BIOS Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    localparam BIOS_AWIDTH = 12;
    wire [BIOS_AWIDTH-1:0] bios_addra, bios_addrb;
    wire [DWIDTH-1:0]      bios_douta, bios_doutb;
    wire                   bios_ena, bios_enb;
    SYNC_ROM_DP #(.AWIDTH(BIOS_AWIDTH),
                  .DWIDTH(DWIDTH),
                  .MIF_HEX(BIOS_MIF_HEX))
    bios_mem(.q0(bios_douta),
             .addr0(bios_addra),
             .en0(bios_ena),
             .q1(bios_doutb),
             .addr1(bios_addrb),
             .en1(bios_enb),
             .clk(clk));

    // Data Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    localparam DMEM_AWIDTH = 14;
    wire [DMEM_AWIDTH-1:0] dmem_addra;
    wire [DWIDTH-1:0]      dmem_dina, dmem_douta;
    wire [BEWIDTH-1:0]     dmem_wbea;
    wire                   dmem_ena;
    SYNC_RAM_WBE #(.AWIDTH(DMEM_AWIDTH),
                   .DWIDTH(DWIDTH))
    dmem (.q(dmem_douta),
          .d(dmem_dina),
          .addr(dmem_addra),
          .wbe(dmem_wbea),
          .en(dmem_ena),
          .clk(clk));

    // Instruction Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    localparam IMEM_AWIDTH = 14;
    wire [IMEM_AWIDTH-1:0] imem_addra, imem_addrb;
    wire [DWIDTH-1:0]      imem_douta, imem_doutb;
    wire [DWIDTH-1:0]      imem_dina, imem_dinb;
    wire [BEWIDTH-1:0]       imem_wbea, imem_wbeb;
    wire                   imem_ena, imem_enb;
    SYNC_RAM_DP_WBE #(.AWIDTH(IMEM_AWIDTH),
                      .DWIDTH(DWIDTH))
    imem (.q0(imem_douta),
          .d0(imem_dina),
          .addr0(imem_addra),
          .wbe0(imem_wbea),
          .en0(imem_ena),
          .q1(imem_doutb),
          .d1(imem_dinb),
          .addr1(imem_addrb),
          .wbe1(imem_wbeb),
          .en1(imem_enb),
          .clk(clk));

    //////////////////////////////////////////////////
    ////  
    ////    Mem Specific Signals Begin
    ////
    //////////////////////////////////////////////////
    
    assign bios_ena = 1'b1;     // TODO: Attach enable to reset
    assign bios_enb = 1'b1;     // TODO: Check synchronous operation of BIOS/IMEM vs Pipeline Regisers  
    assign dmem_ena = 1'b1;
    assign imem_ena = 1'b1;
    assign imem_enb = ~rst;
    assign imem_wbeb = 4'b0;   
     
    //////////////////////////////////////////////////
    ////  
    ////    Mem Specific Signals End
    ////
    //////////////////////////////////////////////////

    // Register file
    // Asynchronous read: read data is available in the same cycle
    // Synchronous write: write takes one cycle
    localparam RF_AWIDTH = 5;
    wire [RF_AWIDTH-1:0]   wa, ra1, ra2;
    wire [DWIDTH-1:0]      wd, rd1, rd2;
    wire                   we;
    ASYNC_RAM_1W2R # (.AWIDTH(RF_AWIDTH),
                      .DWIDTH(DWIDTH))
    rf (.addr0(wa),
        .d0(wd),
        .we0(we),
        .q1(rd1),
        .addr1(ra1),
        .q2(rd2),
        .addr2(ra2),
        .clk(clk));

    // On-chip UART
    //// UART Receiver
    wire [7:0]             uart_rx_data_out;
    wire                   uart_rx_data_out_valid;
    wire                   uart_rx_data_out_ready;
    //// UART Transmitter
    wire [7:0]             uart_tx_data_in;
    wire                   uart_tx_data_in_valid;
    wire                   uart_tx_data_in_ready;
    uart #(.CLOCK_FREQ(CPU_CLOCK_FREQ),
           .BAUD_RATE(BAUD_RATE))
    on_chip_uart (.clk(clk),
                  .reset(rst),
                  .serial_in(serial_in),
                  .data_out(uart_rx_data_out),
                  .data_out_valid(uart_rx_data_out_valid),
                  .data_out_ready(uart_rx_data_out_ready),
                  .serial_out(serial_out),
                  .data_in(uart_tx_data_in),
                  .data_in_valid(uart_tx_data_in_valid),
                  .data_in_ready(uart_tx_data_in_ready));

    // CSR
    wire [DWIDTH-1:0]      csr_dout, csr_din;
    wire                   csr_we;
    REGISTER_R_CE #(.N(DWIDTH))
    csr (.q(csr_dout),
         .d(csr_din),
         .rst(rst),
         .ce(csr_we),
         .clk(clk));

    // TODO: Your code to implement a fully functioning RISC-V core
    // Add as many modules as you want
    // Feel free to move the memory modules around
  
    wire [DWIDTH-1:0] pc_IF;
    wire [DWIDTH-1:0] pc_sel_mux_out;
    mux3 #(.N(DWIDTH))
    pc_sel_mux (.in0(pc_IF + 4),
                .in1(32'b0),
                .in2(32'b0),
                .sel(2'b0),
                .out(pc_sel_mux_out));

    REGISTER_R_CE #(.N(DWIDTH))
    pc_reg (.q(pc_IF),
            .d(pc_sel_mux_out),
            .rst(rst),
            .ce(1'b1),
            .clk(clk));

    assign imem_addrb = pc_IF[15:2];
    assign bios_addra = pc_IF[11:0];

    wire [DWIDTH-1:0] instr_IF = imem_doutb;

    ////////////////////////////////////////////////////
    //
    //     ID Stage BEGIN 
    //
    ////////////////////////////////////////////////////

    wire [DWIDTH-1:0] instr_ID = instr_IF;
    assign ra1 = instr_IF[19:15];
    assign ra2 = instr_IF[24:20];

    // Control Decoder
    wire [ROM_IDX_WIDTH-1:0] rom_index;
    control_decode
    ctrl_dec (.instr(instr_ID),
              .ROMIn(rom_index));
    // Control ROM
    wire [CWIDTH-1:0] ctrl_ID;
    control_unit
    control(.dec_instr_code(rom_index),
	        .hex_instr_code(ctrl_ID));

    // Immediate Generator 
    wire [DWIDTH-1:0] imm_ID;
    wire [2:0] imm_sel_ID = ctrl_ID[3:1];
    imm_generator #(.N(DWIDTH))
    imm_gen (.instr(instr_ID),
             .imm_sel(imm_sel_ID[1:0]),
             .imm(imm_ID));

    ////////////////////////////////////////////////////
    //
    //     ID Stage END
    //
    ////////////////////////////////////////////////////

    wire [DWIDTH-1:0] imm_X;
    REGISTER_R_CE #(.N(DWIDTH))
    imm_ID_X (.q(imm_X),
              .d(imm_ID),
              .rst(rst),
              .ce(1'b1),
              .clk(clk));

    wire [CWIDTH-1:0] ctrl_X;
    REGISTER_R_CE #(.N(CWIDTH))
    ctrl_ID_X (.q(ctrl_X),
               .d(ctrl_ID),
               .rst(rst),
               .ce(1'b1),
               .clk(clk));

    wire [DWIDTH-1:0] rs1_X;
    REGISTER_R_CE #(.N(DWIDTH))
    rs1_ID_X (.q(rs1_X),
              .d(rd1),
              .rst(rst),
              .ce(1'b1),
              .clk(clk));

    wire [DWIDTH-1:0] rs2_X;
    REGISTER_R_CE #(.N(DWIDTH))
    rs2_ID_X (.q(rs2_X),
              .d(rd2),
              .rst(rst),
              .ce(1'b1),
              .clk(clk));

    wire [DWIDTH-1:0] instr_X;
    REGISTER_R_CE #(.N(DWIDTH))
    instr_ID_X (.q(instr_X),
                .d(instr_ID),
                .rst(rst),
                .ce(1'b1),
                .clk(clk));

    ////////////////////////////////////////////////////
    //
    //     X Stage BEGIN
    //
    ////////////////////////////////////////////////////
    
    wire [3:0] ALUSel_X = ctrl_X[10:7];

    wire [DWIDTH-1:0] alu_res_X;
    alu #(.N(DWIDTH))
    alu_unit (.A(rs1_X),
              .B(imm_X),
              .ALUSel(ALUSel_X),
              .ALURes(alu_res_X));

    ////////////////////////////////////////////////////
    //
    //     X Stage END 
    //
    ////////////////////////////////////////////////////

    wire [DWIDTH-1:0] alu_res_WB;
    REGISTER_R_CE #(.N(DWIDTH))
    alu_X_WB (.q(alu_res_WB),
              .d(alu_res_X),
              .rst(rst),
              .ce(1'b1),
              .clk(clk));

    wire [CWIDTH-1:0] ctrl_WB;
    REGISTER_R_CE #(.N(CWIDTH))
    ctrl_X_WB (.q(ctrl_WB),
               .d(ctrl_X),
               .rst(rst),
               .ce(1'b1),
               .clk(clk));

    wire [DWIDTH-1:0] instr_WB;
    REGISTER_R_CE #(.N(DWIDTH))
    instr_X_WB (.q(instr_WB),
                .d(instr_X),
                .rst(rst),
                .ce(1'b1),
                .clk(clk));

    ////////////////////////////////////////////////////
    //
    //     WB Stage BEGIN 
    //
    ////////////////////////////////////////////////////

    wire [DWIDTH-1:0] res_WB = alu_res_WB;
    wire RegWEn = ctrl_WB[0];

    assign wa = instr_WB[11:7]; 
    assign wd = res_WB;
    assign we = wa == X0_ADDR ? 1'b0 : RegWEn;

endmodule
