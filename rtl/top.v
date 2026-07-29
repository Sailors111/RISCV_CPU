
module top (
    input clk,
    input rst_n,

    output wire [31:0] if_id_pc_out,
    output wire [31:0] if_id_instr_out,

    output wire [4:0] rd,        // 目标寄存器编号
    output wire [4:0] rs1,       // 源寄存器1编号
    output wire [4:0] rs2,       // 源寄存器2编号
    output wire [31:0] imm,      // 立即数（扩展后）
    output wire [4:0] alu_op,    // ALU操作码
    output wire op1_sel,          // ALU第一操作数选择
    output wire op2_sel,         // ALU第二操作数选择
    output wire [1:0] wb_sel,    // 写回数据选择
    output wire [1:0] branch_type, // 分支/跳转类型
    output wire reg_write,
    output wire is_mem_read,
    output wire is_mem_write,
    output wire [4:0] shamt,      // 移位位数

    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    // 第1级：取指（IF）
    wire [31:0] if_pc;
    wire [31:0] if_instr;
    wire [31:0] pc_next;

    assign pc_next = if_pc + 32'd4;

    IF u_if(
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(if_pc),
        .instr(if_instr)
    ); 

    // IF/ID 级间寄存器
    reg [31:0] if_id_pc;
    reg [31:0] if_id_instr;
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            if_id_pc    <= 32'h0;
            if_id_instr <= 32'h00000013;  // NOP
        end else begin
            if_id_pc    <= if_pc;
            if_id_instr <= if_instr;
        end
    end

    assign if_id_pc_out = if_id_pc;
    assign if_id_instr_out = if_id_instr;

    // 还未真的执行WB
    wire wb_reg_write;
    wire [4:0] wb_rd;
    wire [31:0] wb_wdata;

    assign wb_reg_write = 1'b0;
    assign wb_rd        = 5'd0;
    assign wb_wdata     = 32'h0;

    // 第2级：译码（ID）
    wire [31:0] id_pc;
    wire [31:0] id_instr;
    wire [4:0] id_rd;
    wire [4:0] id_rs1;
    wire [4:0] id_rs2;
    wire [31:0] id_imm;
    wire [4:0] id_alu_op;
    wire id_op1_sel;
    wire id_op2_sel;
    wire [1:0] id_wb_sel;
    wire [1:0] id_branch_type;
    wire id_reg_write;
    wire id_is_mem_read;
    wire id_is_mem_write;
    wire [4:0] id_shamt;
    wire [31:0] id_rs1_data;
    wire [31:0] id_rs2_data;

    ID u_id(
        .clk(clk),
        .rst_n(rst_n),

        .if_pc(if_id_pc),
        .if_instr(if_id_instr),

        .wb_reg_write(wb_reg_write),
        .wb_rd(wb_rd),
        .wb_wdata(wb_wdata),

        .pc(id_pc),
        .instr(id_instr),

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
        .shamt(id_shamt),
        
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
    reg [4:0] id_ex_shamt;
    reg id_ex_op1_sel;
    reg id_ex_op2_sel;
    reg [1:0] id_ex_wb_sel;
    reg [1:0] id_ex_branch_type;
    reg id_ex_is_mem_read;
    reg id_ex_is_mem_write;
    reg id_ex_reg_write;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_ex_pc <= 32'h0;
            id_ex_rs1_data <= 32'h0;
            id_ex_rs2_data <= 32'h0;
            id_ex_imm <= 32'h0;
            id_ex_rd <= 5'h0;
            id_ex_rs1 <= 5'h0;
            id_ex_rs2 <= 5'h0;
            id_ex_alu_op <= 5'h0;
            id_ex_shamt <= 5'h0;
            id_ex_op1_sel <= 1'b0;
            id_ex_op2_sel <= 1'b0;
            id_ex_wb_sel <= 2'b0;
            id_ex_branch_type <= 2'b0;
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
            id_ex_shamt <= id_shamt;
            id_ex_op1_sel <= id_op1_sel;
            id_ex_op2_sel <= id_op2_sel;
            id_ex_wb_sel <= id_wb_sel;
            id_ex_branch_type <= id_branch_type;
            id_ex_is_mem_read <= id_is_mem_read;
            id_ex_is_mem_write <= id_is_mem_write;
            id_ex_reg_write <= id_reg_write;
        end
    end

    assign rd = id_ex_rd;
    assign rs1 = id_ex_rs1;
    assign rs2 = id_ex_rs2;
    assign imm = id_ex_imm;
    assign alu_op = id_ex_alu_op;
    assign op1_sel = id_ex_op1_sel;
    assign op2_sel = id_ex_op2_sel;
    assign wb_sel = id_ex_wb_sel;
    assign branch_type = id_ex_branch_type;
    assign reg_write = id_ex_reg_write;
    assign is_mem_read = id_ex_is_mem_read;
    assign is_mem_write = id_ex_is_mem_write;
    assign shamt = id_ex_shamt;
    assign rs1_data = id_ex_rs1_data;
    assign rs2_data = id_ex_rs2_data;

    
endmodule

