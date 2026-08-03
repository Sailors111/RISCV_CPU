
`include "rtl/define.v"


module top (
    input clk,
    input rst_n,

    output wire [31:0] if_pc_out,
    output wire [31:0] if_instr_out,

    output wire [31:0] if_id_pc_out,
    output wire [31:0] if_id_instr_out,

    output wire [31:0] id_ex_pc_out,

    output wire [31:0] ex_mem_alu_result_out,
    output wire [31:0] mem_wb_alu_result_out,
    output wire [31:0] mem_wb_mem_data_out,

    output wire [4:0]  wb_rd_out,
    output wire        wb_reg_write_out,
    output wire [31:0] wb_wdata_out
);

    // 第1级：取指（IF）
    wire [31:0] if_pc;
    wire [31:0] if_instr;
    wire [31:0] if_pc_next;
    wire if_pc_write;

    wire [31:0] ex_pc_next;
    wire ex_branch_taken;

    assign if_pc_next = ex_branch_taken ? ex_pc_next : (if_pc + 32'd4);

    IF u_if(
        .clk(clk),
        .rst_n(rst_n),
        .pc_write(if_pc_write),
        .pc_next(if_pc_next),
        .pc(if_pc),
        .instr(if_instr)
    ); 

    // IF/ID 级间寄存器
    reg [31:0] if_id_pc;
    reg [31:0] if_id_instr;

    wire if_id_write;

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            if_id_pc    <= 32'h0;
            if_id_instr <= 32'h00000013;  // NOP
        end else if (if_id_write) begin
            if_id_pc    <= if_pc;
            if_id_instr <= if_instr;
        end
    end

    // 还未真的执行WB
    wire wb_reg_write;
    wire [4:0] wb_rd;
    wire [31:0] wb_wdata;

    // 第2级：译码（ID）
    wire [31:0] id_pc;
    
    wire [4:0] id_rd;
    wire [4:0] id_rs1;
    wire [4:0] id_rs2;
    wire [31:0] id_imm;
    wire [4:0] id_alu_op;
    wire id_op1_sel;
    wire id_op2_sel;
    wire [1:0] id_wb_sel;
    wire [3:0] id_branch_type;
    wire id_reg_write;
    wire id_is_mem_read;
    wire id_is_mem_write;

    wire id_use_rs1;
    wire id_use_rs2;

    wire [31:0] id_rs1_data;
    wire [31:0] id_rs2_data;

    ID u_id(
        .clk(clk),

        .if_pc(if_id_pc),
        .if_instr(if_id_instr),

        .wb_reg_write(wb_reg_write),
        .wb_rd(wb_rd),
        .wb_wdata(wb_wdata),

        .pc(id_pc),

        .rd(id_rd),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .imm(id_imm),
        .alu_op(id_alu_op),
        .op1_sel(id_op1_sel),
        .op2_sel(id_op2_sel),
        .wb_sel(id_wb_sel),
        .branch_type(id_branch_type),
        .reg_write(id_reg_write),
        .is_mem_read(id_is_mem_read),
        .is_mem_write(id_is_mem_write),
        
        .use_rs1(id_use_rs1),
        .use_rs2(id_use_rs2),

        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data)
    );
    
    // ID/EX 级间寄存器
    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_rs1_data;
    reg [31:0] id_ex_rs2_data;
    reg [31:0] id_ex_imm;
    reg [4:0] id_ex_rd;
    reg [4:0] id_ex_rs1;
    reg [4:0] id_ex_rs2;
    reg [4:0] id_ex_alu_op;
    reg id_ex_op1_sel;
    reg id_ex_op2_sel;
    reg [1:0] id_ex_wb_sel;
    reg [3:0] id_ex_branch_type;
    reg id_ex_is_mem_read;
    reg id_ex_is_mem_write;
    reg id_ex_reg_write;

    wire id_ex_flush;


    // 数据冒险：load-use解决方法
    hazard_unit u_hazard_unit(
        .id_ex_is_mem_read(id_ex_is_mem_read),
        .id_ex_rd(id_ex_rd),

        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_use_rs1(id_use_rs1),
        .id_use_rs2(id_use_rs2),

        .pc_write(if_pc_write),
        .if_id_write(if_id_write),
        .id_ex_flush(id_ex_flush)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_ex_pc <= 32'h0;
            id_ex_rs1_data <= 32'h0;
            id_ex_rs2_data <= 32'h0;
            id_ex_imm <= 32'h0;
            id_ex_rd <= 5'h0;
            id_ex_rs1 <= 5'h0;
            id_ex_rs2 <= 5'h0;
            id_ex_alu_op <= `ALU_PASS;
            id_ex_op1_sel <= `OP1_RS1;
            id_ex_op2_sel <= `OP2_RS2;
            id_ex_wb_sel <= `WB_ALU;
            id_ex_branch_type <= `BR_NONE;
            id_ex_is_mem_read <= 1'b0;
            id_ex_is_mem_write <= 1'b0;
            id_ex_reg_write <= 1'b0;
        end else if(id_ex_flush) begin
            // 向 EX 插入 bubble
            id_ex_pc <= 32'h0;
            id_ex_rs1_data <= 32'h0;
            id_ex_rs2_data <= 32'h0;
            id_ex_imm <= 32'h0;
            id_ex_rd <= 5'h0;
            id_ex_rs1 <= 5'h0;
            id_ex_rs2 <= 5'h0;
            id_ex_alu_op <= `ALU_PASS;
            id_ex_op1_sel <= `OP1_RS1;
            id_ex_op2_sel <= `OP2_RS2;
            id_ex_wb_sel <= `WB_ALU;
            id_ex_branch_type <= `BR_NONE;
            id_ex_is_mem_read <= 1'b0;
            id_ex_is_mem_write <= 1'b0;
            id_ex_reg_write <= 1'b0;
        end else begin
            id_ex_pc <= id_pc;
            id_ex_rs1_data <= id_rs1_data;
            id_ex_rs2_data <= id_rs2_data;
            id_ex_imm <= id_imm;
            id_ex_rd <= id_rd;
            id_ex_rs1 <= id_rs1;
            id_ex_rs2 <= id_rs2;
            id_ex_alu_op <= id_alu_op;
            id_ex_op1_sel <= id_op1_sel;
            id_ex_op2_sel <= id_op2_sel;
            id_ex_wb_sel <= id_wb_sel;
            id_ex_branch_type <= id_branch_type;
            id_ex_is_mem_read <= id_is_mem_read;
            id_ex_is_mem_write <= id_is_mem_write;
            id_ex_reg_write <= id_reg_write;
        end
    end

    // 第3级：执行（EX）
    wire [31:0] ex_alu_result;
    wire [31:0] ex_store_data;
    wire [31:0] ex_pc_plus4;

    wire [4:0] ex_rd;
    wire ex_reg_write;
    wire ex_is_mem_read;
    wire ex_is_mem_write;
    wire [1:0] ex_wb_sel;


    wire [31:0] ex_mem_forward_data;
    wire [31:0] mem_wb_forward_data;

    assign ex_mem_forward_data =(ex_mem_wb_sel == `WB_PC4) ? ex_mem_pc_plus4 :
                                 ex_mem_alu_result;
    assign mem_wb_forward_data = wb_wdata;

    wire [31:0] real_rs1_data;
    wire [31:0] real_rs2_data;

    assign real_rs1_data =
        (forward_rs1 == `FORWARD_EX) ? ex_mem_forward_data :
        (forward_rs1 == `FORWARD_MEM) ? mem_wb_forward_data :
                            id_ex_rs1_data;

    assign real_rs2_data =
        (forward_rs2 == `FORWARD_EX) ? ex_mem_forward_data :
        (forward_rs2 == `FORWARD_MEM) ? mem_wb_forward_data :
                            id_ex_rs2_data;


    EX u_ex(
        .id_pc(id_ex_pc),

        .id_rd(id_ex_rd),
        .id_rs1(id_ex_rs1),
        .id_rs2(id_ex_rs2),
        .id_imm(id_ex_imm),
        .id_alu_op(id_ex_alu_op),
        .id_op1_sel(id_ex_op1_sel),
        .id_op2_sel(id_ex_op2_sel),
        .id_wb_sel(id_ex_wb_sel),
        .id_branch_type(id_ex_branch_type),
        .id_reg_write(id_ex_reg_write),
        .id_is_mem_read(id_ex_is_mem_read),
        .id_is_mem_write(id_ex_is_mem_write),

        .id_rs1_data(real_rs1_data),
        .id_rs2_data(real_rs2_data),

        .alu_result(ex_alu_result),
        .store_data(ex_store_data),
        .pc_plus4(ex_pc_plus4),
        .pc_next(ex_pc_next),

        .branch_taken(ex_branch_taken),
        .rd(ex_rd),
        .reg_write(ex_reg_write),
        .is_mem_read(ex_is_mem_read),
        .is_mem_write(ex_is_mem_write),
        .wb_sel(ex_wb_sel)
    );

    // EX/MEM 级间寄存器
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_store_data;
    reg [31:0] ex_mem_pc_plus4;
    reg [4:0]  ex_mem_rd;
    reg        ex_mem_reg_write;
    reg        ex_mem_is_mem_read;
    reg        ex_mem_is_mem_write;
    reg [1:0]  ex_mem_wb_sel;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_mem_alu_result   <= 32'h0;
            ex_mem_store_data   <= 32'h0;
            ex_mem_pc_plus4     <= 32'h0;
            ex_mem_rd           <= 5'h0;
            ex_mem_reg_write    <= 1'b0;
            ex_mem_is_mem_read  <= 1'b0;
            ex_mem_is_mem_write <= 1'b0;
            ex_mem_wb_sel       <= 2'b0;
        end else begin
            ex_mem_alu_result   <= ex_alu_result;
            ex_mem_store_data   <= ex_store_data;
            ex_mem_pc_plus4     <= ex_pc_plus4;
            ex_mem_rd           <= ex_rd;
            ex_mem_reg_write    <= ex_reg_write;
            ex_mem_is_mem_read  <= ex_is_mem_read;
            ex_mem_is_mem_write <= ex_is_mem_write;
            ex_mem_wb_sel       <= ex_wb_sel;
        end
    end


    // 第4级：访存（MEM）
    wire [4:0] mem_rd;
    wire mem_reg_write;
    wire [1:0] mem_wb_sel;

    wire [31:0] mem_pc_plus4;
    wire [31:0] mem_alu_result;
    wire [31:0] mem_data;

    MEM u_mem(
        .clk(clk),

        .ex_alu_result(ex_mem_alu_result),
        .ex_store_data(ex_mem_store_data),

        .ex_is_mem_read(ex_mem_is_mem_read),
        .ex_is_mem_write(ex_mem_is_mem_write),

        .ex_rd(ex_mem_rd),
        .ex_reg_write(ex_mem_reg_write),
        .ex_wb_sel(ex_mem_wb_sel),
        .ex_pc_plus4(ex_mem_pc_plus4),

        .rd(mem_rd),
        .reg_write(mem_reg_write),
        .wb_sel(mem_wb_sel),
        .pc_plus4(mem_pc_plus4),
        .alu_result(mem_alu_result),
        .mem_data(mem_data)
    );

    // MEM/WB 级间寄存器
    reg [4:0] mem_wb_rd;
    reg        mem_wb_reg_write;
    reg [1:0]  mem_wb_wb_sel;

    reg [31:0] mem_wb_alu_result;
    reg [31:0] mem_wb_mem_data;
    reg [31:0] mem_wb_pc_plus4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_wb_rd         <= 5'h0;
            mem_wb_reg_write  <= 1'b0;
            mem_wb_wb_sel     <= 2'b0;
            mem_wb_alu_result <= 32'h0;
            mem_wb_mem_data   <= 32'h0;
            mem_wb_pc_plus4   <= 32'h0;
        end else begin
            mem_wb_rd         <= mem_rd;
            mem_wb_reg_write  <= mem_reg_write;
            mem_wb_wb_sel     <= mem_wb_sel;
            mem_wb_alu_result <= mem_alu_result;
            mem_wb_mem_data   <= mem_data;
            mem_wb_pc_plus4   <= mem_pc_plus4;
        end
    end

    // 第5级：写回（WB）
    WB u_wb(
        .clk(clk),

        .mem_rd(mem_wb_rd),
        .mem_reg_write(mem_wb_reg_write),
        .mem_wb_sel(mem_wb_wb_sel),

        .mem_alu_result(mem_wb_alu_result),
        .mem_data(mem_wb_mem_data),
        .mem_pc_plus4(mem_wb_pc_plus4),

        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),
        .wb_wdata(wb_wdata)
    );

    // 数据冒险：旁路转发技术
    wire [1:0] forward_rs1;
    wire [1:0] forward_rs2;

    forwarding_unit u_forwarding_unit(
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),

        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_is_mem_read(ex_mem_is_mem_read),

        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),

        .forward_rs1(forward_rs1),
        .forward_rs2(forward_rs2)
    );

    // debug output
    assign if_pc_out              = if_pc;
    assign if_instr_out           = if_instr;

    assign if_id_pc_out           = if_id_pc;
    assign if_id_instr_out        = if_id_instr;

    assign id_ex_pc_out           = id_ex_pc;

    assign ex_mem_alu_result_out  = ex_mem_alu_result;
    assign mem_wb_alu_result_out  = mem_wb_alu_result;
    assign mem_wb_mem_data_out    = mem_wb_mem_data;

    assign wb_rd_out              = wb_rd;
    assign wb_reg_write_out       = wb_reg_write;
    assign wb_wdata_out           = wb_wdata;


endmodule

