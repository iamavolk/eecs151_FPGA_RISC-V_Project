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
    localparam HJALR = 16'h2041;
    localparam HCLEAR = 16'h0;
    
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
    
    assign bios_ena = 1'b1;    
    assign bios_enb = 1'b1;     
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
    wire [DWIDTH-1:0] jal_select;
    wire [DWIDTH-1:0] br_jalr_select;
    wire [1:0] pc_select;
    wire [DWIDTH-1:0] pc_sel_mux_out;
    mux3 #(.N(DWIDTH))
    pc_sel_mux (.in0(pc_IF + 4),
                .in1(jal_select),
                .in2(br_jalr_select),
                .sel(pc_select),
                .out(pc_sel_mux_out));

    REGISTER_R_CE #(.N(DWIDTH), .INIT(RESET_PC))
    //REGISTER_R_CE #(.N(DWIDTH))
    pc_reg (.q(pc_IF),
            .d(pc_sel_mux_out),
            .rst(rst),
            .ce(1'b1),
            .clk(clk));

    wire [DWIDTH-1:0] pc_ID;
    REGISTER_R_CE #(.N(DWIDTH))
    pc_IF_ID (.q(pc_ID),
	          .d(pc_IF),
	          .rst(rst),
	          .ce(1'b1),
	          .clk(clk));

    assign imem_addrb = pc_IF[15:2];
    assign bios_addra = pc_IF[13:2];

    // Instruction fetch
    wire [DWIDTH-1:0] instr_IF;
    mux2 #(.N(DWIDTH))
    pc_30_mux (.in0(imem_doutb),
               .in1(bios_douta),
               .sel(pc_IF[30]),
               .out(instr_IF));

    // Instr kill iff ctrl redirect (see unit)      
    wire instr_kill_control;
    wire [1:0] pc_sel_check_ID;
    wire [1:0] pc_select_jalrb_WB;
    instr_kill_unit
    instr_kill_ctrl (.pc_select_jal_x(pc_sel_check_ID),
                     .pc_select_jalr_b_wb(pc_select_jalrb_WB),
                     .instr_kill_res(instr_kill_control));

    // Handling consistency immediately after reset
    wire instr_kill = ((pc_IF == 32'h10000000) || (pc_IF == 32'h0) || (pc_IF == 32'h40000000) || instr_kill_control);
    wire [DWIDTH-1:0] instr_ID;
    mux2 #(.N(DWIDTH))
    instr_kill_mux (.in0(instr_IF),
                    .in1(`CLEAR_NOP),
                    .sel(instr_kill),
                    .out(instr_ID));

    ////////////////////////////////////////////////////
    //
    //     ID Stage BEGIN 
    //
    ////////////////////////////////////////////////////

    assign ra1 = instr_ID[19:15];
    assign ra2 = instr_ID[24:20];

    // FW_ID_MUX_rs1
    wire [DWIDTH-1:0] alu_rs1_res;
    wire [DWIDTH-1:0] wb_rs1_res;
    wire [DWIDTH-1:0] fwd_ID_rs1_res;
    wire [1:0] fw_A;
    mux3 #(.N(DWIDTH))
    fw_ID_mux_rs1 (.in0(rd1),
                   .in1(alu_rs1_res),
                   .in2(wb_rs1_res),
                   .sel(fw_A),
                   .out(fwd_ID_rs1_res));

    // FW_ID_MUX_rs2
    wire [DWIDTH-1:0] alu_rs2_res;
    wire [DWIDTH-1:0] wb_rs2_res;
    wire [DWIDTH-1:0] fwd_ID_rs2_res;
    wire [1:0] fw_B;
    mux3 #(.N(DWIDTH))
    fw_ID_mux_rs2 (.in0(rd2),
                   .in1(alu_rs2_res),
                   .in2(wb_rs2_res),
                   .sel(fw_B),
                   .out(fwd_ID_rs2_res));

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

    // JAL in ID-stage results in redirect
    jal_unit
    jump_and_link (.instr(instr_ID),
                   .pc(pc_ID),
		           .jal_pc(jal_select));

    wire [1:0] pc_sel_jal_ID = (ctrl_ID == HJAL) ? 2'b01 : 2'b00;

    ////////////////////////////////////////////////////
    //
    //     ID Stage END
    //
    ////////////////////////////////////////////////////

    wire [1:0] pc_sel_jal_X;
    REGISTER_R_CE #(.N(2))
    pc_sel_jal_ID_X (.q(pc_sel_jal_X),
                     .d(pc_sel_jal_ID),
                     .rst(rst),
                     .ce(1'b1),
                     .clk(clk));
    assign pc_sel_check_ID = pc_sel_jal_X;

    wire [DWIDTH-1:0] imm_X;
    REGISTER_R_CE #(.N(DWIDTH))
    imm_ID_X (.q(imm_X),
              .d(imm_ID),
              .rst(rst),
              .ce(1'b1),
              .clk(clk));

    wire [CWIDTH-1:0] ctrl_X_pre;
    REGISTER_R_CE #(.N(CWIDTH))
    ctrl_ID_X (.q(ctrl_X_pre),
               .d(ctrl_ID),
               .rst(rst),
               .ce(1'b1),
               .clk(clk));

    wire [DWIDTH-1:0] rs1_X;
    REGISTER_R_CE #(.N(DWIDTH))
    rs1_ID_X (.q(rs1_X),
              //.d(rd1),
              .d(fwd_ID_rs1_res),
              .rst(rst),
              .ce(1'b1),
              .clk(clk));

    wire [DWIDTH-1:0] rs2_X;
    REGISTER_R_CE #(.N(DWIDTH))
    rs2_ID_X (.q(rs2_X),
              //.d(rd2),
              .d(fwd_ID_rs2_res),
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

    wire [DWIDTH-1:0] pc_X;
    REGISTER_R_CE #(.N(DWIDTH))
    pc_ID_X (.q(pc_X),
	         .d(pc_ID),
	         .rst(rst),
	         .ce(1'b1),
	         .clk(clk));

    wire [DWIDTH-1:0] csr_uimm_X;
    wire [DWIDTH-1:0] csr_uimm_extend = {27'b0,instr_ID[19:15]};
    REGISTER_R_CE #(.N(DWIDTH))
    csr_uImm_ID_X (.q(csr_uimm_X),
                   .d(csr_uimm_extend),
                   .rst(rst),
                   .ce(1'b1),
                   .clk(clk));

    ////////////////////////////////////////////////////
    //
    //     X Stage BEGIN
    //
    ////////////////////////////////////////////////////
    
    // Ctrl kill mux
    wire [CWIDTH-1:0] ctrl_X;
    wire ctrl_kill_x = (pc_select_jalrb_WB == 2'b10) ? 1'b1 : 1'b0;
    mux2 #(.N(CWIDTH))
    ctrl_kill_mux (.in0(ctrl_X_pre),
                   .in1(HCLEAR),
                   .sel(ctrl_kill_x),
                   .out(ctrl_X));

    // X-stage control signals
    wire BrLUn = ctrl_X[4];
    wire [3:0] ALUSel_X = ctrl_X[10:7];
    wire ASel = ctrl_X[5];
    wire BSel = ctrl_X[6];
    wire MemRW = ctrl_X[11];
    wire RegWEn_X = ctrl_X[0];


    // Forwarding mux A for BR after LOAD -- fwd into Branch Comparator 
    wire [DWIDTH-1:0] fwd_branch_rs1;
    wire [DWIDTH-1:0] wb_res_br_A;
    wire fw_branch_A;
    mux2 #(.N(DWIDTH))
    fwd_br_mux_A (.in0(rs1_X),
                  .in1(wb_res_br_A),
                  .sel(fw_branch_A),
                  .out(fwd_branch_rs1));
    
    // Forwarding mux B for BR after LOAD -- fwd into Branch Comparator 
    wire [DWIDTH-1:0] fwd_branch_rs2;
    wire [DWIDTH-1:0] wb_res_br_B;
    wire fw_branch_B;
    mux2 #(.N(DWIDTH))
    fwd_br_mux_B (.in0(rs2_X),
                  .in1(wb_res_br_B),
                  .sel(fw_branch_B),
                  .out(fwd_branch_rs2));

    // Branch Comparator
    wire BrEq;
    wire BrLt;
    branch_comp #(.N(DWIDTH))
    br_comp (.br_data0(fwd_branch_rs1), // changed from rs1_X to current arg
             .br_data1(fwd_branch_rs2), // changed from rs2_X to current arg
             .BrUn(BrLUn),
             .BrEq(BrEq),
             .BrLt(BrLt));

    // CSR mux 
    wire [DWIDTH-1:0] csr_X;
    mux2 #(.N(DWIDTH))
    csr_mux_X (.in0(rs1_X),
               .in1(csr_uimm_X),
               .sel(instr_X[14]),
               .out(csr_X));
    assign csr_din = csr_X;
    assign csr_we = (instr_X[6:0] == `OPC_CSR) ? 1'b1 : 1'b0;                              // TODO: change, subject to instr_WB 

    wire [DWIDTH-1:0] alu_A;
    mux2 #(.N(DWIDTH))
    alu_A_mux (.in0(fwd_branch_rs1),
	           .in1(pc_X),
	           .sel(ASel),
	           .out(alu_A));

    wire [DWIDTH-1:0] alu_B;
    mux2 #(.N(DWIDTH))
    alu_B_mux (.in0(fwd_branch_rs2),
	           .in1(imm_X),
	           .sel(BSel),
	           .out(alu_B));

    wire [DWIDTH-1:0] alu_res_X;
    wire uart_store_selected;

    alu #(.N(DWIDTH))
    alu_unit (.A(alu_A),
              .B(alu_B),
              .ALUSel(ALUSel_X),
              .ALURes(alu_res_X));
    assign alu_rs1_res = alu_res_X;
    assign alu_rs2_res = alu_res_X;

    assign br_jalr_select = alu_res_X;

    assign uart_store_selected = ((alu_res_X == 32'h80000008) && (instr_X[6:0] == `OPC_STORE));
    assign uart_tx_data_in_valid = uart_store_selected;                                                  // TODO: Drives uart at X stage --> check with TAs is incorrect / need to drive at WB stage?
    wire ctr_reset = (alu_res_X == 32'h80000018);


    // PC select unit, based on the previous (jal vs non-jal) and current (jalr or branch) result. This result propagates to WB   
    wire [1:0] pc_sel_x;
    pc_sel_unit
    pc_select_unit (.instr_hex(ctrl_X),
                    .pc_sel_id(pc_sel_jal_ID),
                    .BrEq(BrEq),
                    .BrLt(BrLt),
                    .pc_sel_x(pc_sel_x),
                    .PCSel(pc_select));

    // Mask selector, pre-MEM entry data processing
    wire [3:0] dmem_mask, imem_mask;
    wire [DWIDTH-1:0] rs2_X_shifted;
    wire [1:0] offset = alu_res_X[1:0];
    mem_wb_select #(.WIDTH(DWIDTH))
    mem_mask (.mem_write(MemRW),
              .instr(instr_X),
              //.data_in(rs2_X),
              .data_in(fwd_branch_rs2),
              .addr_alu_res(alu_res_X[31:28]),
              .offset(offset),
              .dmem_wea_mask(dmem_mask),
              .imem_wea_mask(imem_mask),
              .data_out(rs2_X_shifted));
    
    // Enter signals to BIOS, IMEM, DMEM, MMIO (uart)
    assign bios_addrb = alu_res_X[13:2];
    assign dmem_wbea = dmem_mask;
    assign imem_wbea = imem_mask;
    assign dmem_addra = alu_res_X[15:2];
    assign imem_addra = alu_res_X[15:2];
    assign dmem_dina = rs2_X_shifted;
    assign imem_dina = rs2_X_shifted;
    assign uart_tx_data_in = fwd_branch_rs2[7:0];

    //wire bubble_inside = ((ctrl_X == 16'h0) || (ctrl_X == 16'h80));                      // TODO : Use bubble_inside to determine if +1 is needed for instruction counter at commit point (WB stage)
    //wire bubble_inside = ((ctrl_X == 16'h25) || (ctrl_X == 16'h80));                      // TODO : Use bubble_inside to determine if +1 is needed for instruction counter at commit point (WB stage)
    wire bubble_inside = ((instr_X == `INST_NOP) || (instr_X == `CLEAR_NOP) || (ctrl_X == HCLEAR)) ? 1'b1: 1'b0;                      // TODO : Use bubble_inside to determine if +1 is needed for instruction counter at commit point (WB stage)

    ////////////////////////////////////////////////////
    //
    //     X Stage END 
    //
    ////////////////////////////////////////////////////
    wire bubble_inside_wb;
    REGISTER_R_CE #(.N(1), .INIT(1'b0))
    bubble_X_WB (.q(bubble_inside_wb),
                 .d(bubble_inside),
                 .rst(rst),
                 .ce(1'b1),
                 .clk(clk));

    wire [1:0] pc_select_WB;
    REGISTER_R_CE #(.N(2))
    pc_select_X_WB (.q(pc_select_WB),
                    .d(pc_sel_x),
                    .rst(rst),
                    .ce(1'b1),
                    .clk(clk));
    assign pc_select_jalrb_WB = pc_select_WB; 

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

    // CSR after X, commit point past-WB stage, currently works without
    //wire [DWIDTH-1:0] csr_WB;
    //REGISTER_R_CE #(.N(DWIDTH))
    //csr_X_WB (.q(csr_WB),
    //          .d(csr_X),
    //          .rst(rst),
    //          .ce(1'b1),
    //          .clk(clk));

    wire [DWIDTH-1:0] pc_WB;
    REGISTER_R_CE #(.N(DWIDTH))
    pc_X_WB (.q(pc_WB),
             .d(pc_X),
             .rst(rst),
             .ce(1'b1),
             .clk(clk));

    ////////////////////////////////////////////////////
    //
    //     WB Stage BEGIN 
    //
    ////////////////////////////////////////////////////


    ////////////////////////////////////////////////////
    // COUNTERS
    ////////////////////////////////////////////////////
    // Cycle Counter
    wire [DWIDTH-1:0] cycle_counter_d;
    wire [DWIDTH-1:0] cycle_counter_q;
    REGISTER_R_CE #(.N(DWIDTH), .INIT(32'd0))
    cyc_ctr (.q(cycle_counter_q),
             .d(cycle_counter_d),
             .rst(ctr_reset || rst),
             .ce(1'b1),
             .clk(clk));
    assign cycle_counter_d = cycle_counter_q + 1;
    // Instruction Counter
    wire [DWIDTH-1:0] instr_counter_d;
    wire [DWIDTH-1:0] instr_counter_q;
    REGISTER_R_CE #(.N(DWIDTH), .INIT(32'b0))
    instr_ctr (.q(instr_counter_q),
               .d(instr_counter_d),
               .rst(ctr_reset || rst),
               .ce(~bubble_inside_wb),
               .clk(clk));
    //assign instr_counter_d = (instr_WB[6:0] != `OPC_KILL) ? instr_counter_q : instr_counter_q + 1;
    assign instr_counter_d = instr_counter_q + 1;
    ////////////////////////////////////////////////////

    wire [DWIDTH-1:0] mem_output;
    wire uart_load_selected;
    mem_output #(.WIDTH(DWIDTH))
    mem_res_unit (.dmem_out(dmem_douta),
                  .bios_out(bios_doutb),
                  .alu_addr(alu_res_WB),                                                         // TODO: check alu_res_X vs alu_res_WB / check with test suite, possibly WB is correct
                  .uart_rx_valid(uart_rx_data_out_valid),
                  .uart_tx_ready(uart_tx_data_in_ready),
                  .uart_rx_out(uart_rx_data_out),
                  .cyc_ctr(cycle_counter_q),                                                     // TODO: cycle ctr
                  .instr_ctr(instr_counter_q),                                                   // TODO: instr ctr
                  .mem_result(mem_output),
                  .uart_load_selected(uart_load_selected));

    assign uart_rx_data_out_ready = uart_load_selected;                                          // TODO: uart_RX is driven at WB stage, whereas uart_TX is at X stage ?

    // Memory output masking for lw, lh(u), lb(u)
    wire [DWIDTH-1:0] mem_masked;
    //mem_load_mask #(.N(DWIDTH))
    mem_load_mask_eff #(.WIDTH(DWIDTH))
    mem_mask_unit (.addr(alu_res_WB[1:0]),
                   .func3(instr_WB[14:12]),
                   .mem_res(mem_output),
                   .mem_masked_out(mem_masked));

    wire RegWEn = ctrl_WB[0];
    wire [1:0] WBSel = ctrl_WB[13:12];

    // Write-back selector
    wire [DWIDTH-1:0] res_WB;
    mux3 #(.N(DWIDTH))
    wb_mux (.in0(mem_masked),
            .in1(alu_res_WB),
            .in2(pc_WB + 4),
            .sel(WBSel),
            .out(res_WB));

    // Writeback wire forwared to X, ID stages
    assign wb_rs1_res = res_WB;
    assign wb_rs2_res = res_WB;
    assign wb_res_br_A = res_WB;
    assign wb_res_br_B = res_WB;

    // RegFile signals. wa = addr0, wd = data0, we is asserted unless rd = x0 
    assign wa = instr_WB[11:7];
    assign wd = res_WB;
    assign we = wa == X0_ADDR ? 1'b0 : RegWEn;

    // Forwarding unit, needs optimization
    fwd_unit
    forwarding (.rf_wen_X(RegWEn_X),
                .rf_wen_WB(RegWEn),
                .opcode(instr_WB[6:0]),
                .rd_X(instr_X[11:7]),
                .rd_WB(instr_WB[11:7]),
                .rs1_ID(instr_ID[19:15]),
                .rs2_ID(instr_ID[24:20]),
                .rs1_X(instr_X[19:15]),
                .rs2_X(instr_X[24:20]),
                .fw_ID_A(fw_A), 
                .fw_ID_B(fw_B),
                .fw_X_br_A(fw_branch_A),
                .fw_X_br_B(fw_branch_B));
endmodule
