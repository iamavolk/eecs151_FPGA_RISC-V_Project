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

    localparam DWIDTH = 32;
    localparam BEWIDTH = DWIDTH / 8;
    localparam CWIDTH = 16;
    localparam CTRL_KILL = 16'b0; 
    
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
    wire [BEWIDTH:0]       imem_wbea, imem_wbeb;
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
  
    // PC
    wire [DWIDTH-1:0] pc_IF;
    REGISTER_R_CE #(.N(DWIDTH))
    pc_reg  (.q(pc_IF),
             .d(...),
             .rst(rst),
             .ce(1'b1),
             .clk(clk));

    assign bios_addra = pc_IF[11:0];
    assign imem_addrb = pc_IF[13:0];
 
    wire [DWIDTH-1:0] pc_ID;
    REGISTER_R_CE #(.N(DWIDTH))
    pc_IF_ID (.q(pc_ID),
              .d(pc_IF),
              .rst(rst),
              .ce(1'b1),
              .clk(clk));
     
    ////////////////////////////////////////////////////
    //
    //     ID Stage begin
    //
    ////////////////////////////////////////////////////


    // Instr
    wire instr_ID;
    mux2 #(.N(DWIDTH))
    pc_30_mux (.in0(imem_doutb),
               .in1(bios_douta),
               .sel(pc_ID[30]),
               .out(instr_ID));

    //mux2 #(.N(DWIDTH))
    //pc_31_mux (.in0(),
    //           .in1(),
    //           .out());

    assign ra1 = instr_ID[19:15]
    assign ra2 = instr_ID[24:20]

    // Immediate Select
    wire imm_ID;
    imm_generator #(.N(DWIDTH))
    imm_gen (.instr(instr_ID)),
             .imm_sel(ImmSel_ID)),
             .imm(imm_ID));

    
    // Control Decoder
    wire rom_idx;
    control_decode #(.N(DWIDTH))
    ctrl_dec (.instr(instr_ID)),
              .ROMIn(rom_idx));


    // Control ROM
    wire [CWIDTH-1:0] ctrl_encoded;
    control_unit
    control(.dec_instr_code(rom_idx),
	    .hex_instr_code(ctrl_encoded));

    //wire RegWEn = ctrl_encoded[0];
    //wire ImmSel_ID = ctrl_encoded[3:1];
    //wire BrLUn = ctrl_encoded[4];
    //wire ASel = ctrl_encoded[5];
    //wire BSel = ctrl_encoded[6];
    //wire ALUSel = ctrl_encoded[10:7];
    //wire MemRW = ctrl_encoded[11];
    //wire WBSel = ctrl_encoded[13:12];

    // Control ID
    wire ctrl_ID;
    mux2 #(.N(CWIDTH))
    zero_ctrl_mux (.in0(ctrl_encoded),
                   .in1(CTRL_KILL),
                   .sel(1'b0),
                   .out(ctrl_ID));

    wire [2:0] ImmSel_ID = ctrl_ID[3:1];

    ////////////////////////////////////////////////////
    //
    //     ID Stage end
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

    wire [DWIDTH-1:0] instr_X;
    REGISTER_R_CE #(.N(DWIDTH))
    instr_ID_X (.q(instr_X),
                .d(instr_ID),
                .rst(rst),
                .ce(1'b1),
                .clk(clk));

    wire [DWIDTH-1:0] csr_uimm_X;
    REGISTER_R_CE #(.N(DWIDTH))
    csr_uImm_ID_X (.q(csr_uimm_X),
                .d({27{1'b0},instr_ID[19:15]}),
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

    wire [DWIDTH-1:0] pc_X;
    REGISTER_R_CE #(.N(DWIDTH))
    pc_ID_X (.q(pc_X),
             .d(rd1),
             .rst(rst),
             .ce(1'b1),
             .clk(clk));
    
    ////////////////////////////////////////////////////
    //
    //     X Stage begin
    //
    ////////////////////////////////////////////////////
    
    //wire RegWEn = ctrl_encoded[0];
    //wire ImmSel_ID = ctrl_encoded[3:1];
    wire BrLUn = ctrl_X[4];
    wire ASel = ctrl_X[5];
    wire BSel = ctrl_X[6];
    wire [4:0] ALUSel_X = ctrl_X[10:7];
    wire MemRW = ctrl_X[11];
    //wire WBSel = ctrl_encoded[13:12];
    
    // Branch Comp
    wire BrEq_res;
    wire BrLt_res;
    branch_comp #(.N(DWIDTH))
    br_comp (.br_data0(rs1_X),
             .br_data1(rs2_X),
             .BrUn(BrLUn),
             .BrEq(BrEq_res),
             .BrLt(BrLt_res));

    // CSR mux 
    wire csr_X;
    mux2 #(.N(DWIDTH))
    csr_mux_X (.in0(rs1_X),
               .in1(csr_uimm_X),
               .sel(instr_X[14]),
               .out(csr_X));
    
    // FW-X_mux_A
    wire fw_a;
    fw_a_mux #(.N(DWIDTH))
               .in0(rs1_X),
               .in1({32'b0}),        // Forwarding from WB stage
               .sel(1'b0),           // FW_A selector from FORWARDING UNIT
               .out(fw_a));
    
    // FW-X_mux_B
    wire fw_b;
    fw_b_mux #(.N(DWIDTH))
               .in0(rs2_X),
               .in1({32'b0}),        // Forwarding from WB stage
               .sel(1'b0),           // FW_B selector from FORWARDING UNIT
               .out(fw_b));
    
    // ASel mux
    wire alu_A;
    alu_A_mux #(.N(DWIDTH))
                .in0(fw_a),
                .in1(pc_X),        
                .sel(1'b0),          // ASel  
                .out(alu_A));
    
    // BSel mux
    wire alu_B;
    alu_B_mux #(.N(DWIDTH))
                .in0(fw_b),
                .in1(imm_X),        
                .sel(1'b0),          // BSel  
                .out(alu_B));
    // ALU
    wire alu_res;
    alu #(.N(DWIDTH))
          .A(alu_A),
          .B(alu_B),
          .ALUSel(ALUSel_X),                
          .ALURes(alu_res));

    
    /////
    //     BIOS, DMEM, IMEM, IO connections
    /////


    ////////////////////////////////////////////////////
    //
    //     X Stage end
    //
    ////////////////////////////////////////////////////

    wire [DWIDTH-1:0] alu_res_X;
    REGISTER_R_CE #(.N(DWIDTH))
    alu_X_WB (.q(alu_res_X),
              .d(alu_res),
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

    wire [DWIDTH-1:0] csr_WB;                    // CSR commit point? 1 cycle before the data is written
    REGISTER_R_CE #(.N(DWIDTH))
    csr_X_WB (.q(csr_WB),
              .d(csr_X),
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

    wire [DWIDTH-1:0] pc_WB;
    REGISTER_R_CE #(.N(DWIDTH))
    pc_X_WB (.q(pc_WB),
             .d(pc_X),
             .rst(rst),
             .ce(1'b1),
             .clk(clk));

    ////////////////////////////////////////////////////
    //
    //     WB Stage begin 
    //
    ////////////////////////////////////////////////////

    wire RegWEn = ctrl_WB[0];
    //wire ImmSel_ID = ctrl_encoded[3:1];
    //wire BrLUn = ctrl_X[4];
    //wire ASel = ctrl_X[5];
    //wire BSel = ctrl_X[6];
    //wire ALUSel_X = ctrl_X[10:7];
    //wire MemRW = ctrl_X[11];
    wire [1:0] WBSel = ctrl_WB[13:12];

    wire [DWIDTH-1:0] mem_output;


    wire [DWIDTH-1:0] wb_res;
    mux3 #(.N(DWIDTH))
    csr_mux_X (.in0(pc_X + 4),
               .in1(alu_res),
               .in2(mem_output),                     // Mem output
               .sel(WBSel),                     // WBSel
               .out(wb_res));
    
    assign wa = instr_WB[11:7];
    assign wd = wb_res;
    assign we = RegWEn;

endmodule
