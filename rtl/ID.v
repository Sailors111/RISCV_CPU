

`include "define.v"


module ID(
    input wire clk,
    input wire rst_n,

    // 来自IF/ID级间寄存器
    input wire [31:0] if_pc,
    input wire [31:0] if_instr,

    // 来自WB阶段的寄存器写回信号
    input wire wb_reg_write,
    input wire [4:0] wb_rd,
    input wire [31:0] wb_wdata,

    // 传给下一级的PC和原始指令
    output wire [31:0] pc,
    output wire [31:0] instr,

    // 译码结果
    output wire [6:0] opcode,    // 操作码
    output wire [4:0] rd,        // 目标寄存器编号
    output wire [4:0] rs1,       // 源寄存器1编号
    output wire [4:0] rs2,       // 源寄存器2编号
    output wire [2:0] funct3,    // 功能码3位
    output wire [6:0] funct7,    // 功能码7位
    output wire [31:0] imm,      // 立即数（扩展后）
    output wire [4:0] alu_op,    // ALU操作码
    output wire reg_write,
    output wire is_branch,
    output wire is_mem_read,
    output wire is_mem_write,
    output wire [4:0] shamt,      // 移位位数

    // 从寄存器堆读出的数据
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    decoder u_decoder(
        .instr(if_instr),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm),
        .alu_op(alu_op),
        .reg_write(reg_write),
        .is_branch(is_branch),
        .is_mem_read(is_mem_read),
        .is_mem_write(is_mem_write),
        .shamt(shamt)
    );

    regfile u_regfile(
        .clk(clk),
        .we(wb_reg_write),
        .waddr(wb_rd),
        .wdata(wb_wdata),
        .raddr1(rs1),
        .raddr2(rs2),
        .rdata1(rs1_data),
        .rdata2(rs2_data)
    );

    assign pc = if_pc;
    assign instr = if_instr;

endmodule





