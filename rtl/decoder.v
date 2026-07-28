
`include "define.v"

module decoder(
    input [31:0] instr,         // 输入的指令内容
    output reg [6:0] opcode,    // 操作码
    output reg [4:0] rd,        // 目标寄存器编号
    output reg [4:0] rs1,       // 源寄存器1编号
    output reg [4:0] rs2,       // 源寄存器2编号
    output reg [2:0] funct3,    // 功能码3位
    output reg [6:0] funct7,    // 功能码7位
    output reg [31:0] imm,      // 立即数（扩展后）
    output reg [4:0] alu_op,    // ALU操作码
    output reg reg_write,
    output reg is_branch,
    output reg is_mem_read,
    output reg is_mem_write,
    output reg [4:0] shamt      // 移位位数
);

    // 拼接唯一指令ID
    wire [16:0] ins_id = {instr[6:0], instr[14:12], instr[31:25]};

    // 组合逻辑
    always @(*) begin
        // 字段拆解
        opcode = instr[6:0];
        rd     = instr[11:7];
        rs1    = instr[19:15];
        rs2    = instr[24:20];
        funct3 = instr[14:12];
        funct7 = instr[31:25];
        shamt  = instr[19:15];  // 用于 I 型移位

        // 默认值
        imm       = 32'h0;
        alu_op    = `ALU_PASS;
        reg_write = 1'b0;
        is_branch = 1'b0;
        is_mem_read  = 1'b0;
        is_mem_write = 1'b0;

        // 指令译码
        case (ins_id)
            `ID_ADDI: begin
                imm = {{20{instr[31]}}, instr[31:20]};
                alu_op = `ALU_ADD;
                reg_write = 1'b1;
            end
            `ID_ADD: begin
                alu_op = `ALU_ADD;
                reg_write = 1'b1;
            end
            `ID_SUB: begin
                alu_op = `ALU_SUB;
                reg_write = 1'b1;
            end
            `ID_AND: begin
                alu_op = `ALU_AND;
                reg_write = 1'b1;
            end
            `ID_OR: begin
                alu_op = `ALU_OR;
                reg_write = 1'b1;
            end
            `ID_XOR: begin
                alu_op = `ALU_XOR;
                reg_write = 1'b1;
            end
            `ID_SLL: begin
                alu_op = `ALU_SLL;
                reg_write = 1'b1;
            end
            `ID_SRL: begin
                alu_op = `ALU_SRL;
                reg_write = 1'b1;
            end
            `ID_SRA: begin
                alu_op = `ALU_SRA;
                reg_write = 1'b1;
            end
            `ID_SLLI: begin
                alu_op = `ALU_SLL;
                reg_write = 1'b1;
            end
            `ID_SRLI: begin
                alu_op = `ALU_SRL;
                reg_write = 1'b1;
            end
            `ID_SRAI: begin
                alu_op = `ALU_SRA;
                reg_write = 1'b1;
            end
            `ID_LW: begin
                imm = {{20{instr[31]}}, instr[31:20]};
                alu_op = `ALU_ADD;
                is_mem_read = 1'b1;
                reg_write = 1'b1;
            end
            `ID_SW: begin
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                alu_op = `ALU_ADD;
                is_mem_write = 1'b1;
                reg_write = 1'b0;
            end
            `ID_BEQ: begin
                imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
                alu_op = `ALU_SUB;
                is_branch = 1'b1;
                reg_write = 1'b0;
            end
            default: begin
                // 未识别的指令：当作 NOP
                alu_op    = `ALU_PASS;
                reg_write = 1'b0;
                is_branch = 1'b0;
                is_mem_read  = 1'b0;
                is_mem_write = 1'b0;
                imm       = 32'h0;
            end
        endcase
    end
endmodule


