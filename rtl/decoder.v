
`include "rtl/define.v"

module decoder(
    input wire [31:0] instr,    // 输入的指令内容
 
    output reg [4:0] rd,        // 目标寄存器编号
    output reg [4:0] rs1,       // 源寄存器1编号
    output reg [4:0] rs2,       // 源寄存器2编号
    output reg [31:0] imm,      // 立即数（扩展后）
    output reg [4:0] alu_op,    // ALU操作码
    output reg op1_sel,         // ALU第一操作数选择
    output reg op2_sel,         // ALU第二操作数选择
    output reg [1:0] wb_sel,    // 写回数据选择
    output reg [1:0] branch_type, // 分支/跳转类型
    output reg reg_write,       // 寄存器写使能
    output reg is_mem_read,     // 内存读使能
    output reg is_mem_write     // 内存写使能
);

    reg [6:0] opcode;    // 操作码
    reg [2:0] funct3;    // 功能码3
    reg [6:0] funct7;    // 功能码7

    // 组合逻辑
    always @(*) begin
        // 字段拆解
        opcode = instr[6:0];
        rd     = instr[11:7];
        rs1    = instr[19:15];
        rs2    = instr[24:20];
        funct3 = instr[14:12];
        funct7 = instr[31:25];

        // 默认值
        imm       = 32'h0;
        alu_op    = `ALU_PASS;
        op1_sel   = `OP1_RS1;
        op2_sel   = `OP2_RS2;
        wb_sel    = `WB_ALU;
        branch_type = `BR_NONE;
        reg_write = 1'b0;
        is_mem_read  = 1'b0;
        is_mem_write = 1'b0;

        // 指令译码
        case (opcode)
            `OPCODE_RTYPE: begin
                case ({funct3, funct7})
                    {`F3_ADD_SUB, `F7_ADD}: begin
                        alu_op = `ALU_ADD;
                        reg_write = 1'b1;
                    end
                    {`F3_ADD_SUB, `F7_SUB}: begin
                        alu_op = `ALU_SUB;
                        reg_write = 1'b1;
                    end
                    {`F3_AND, `F7_AND}: begin
                        alu_op = `ALU_AND;
                        reg_write = 1'b1;
                    end
                    {`F3_OR, `F7_OR}: begin
                        alu_op = `ALU_OR;
                        reg_write = 1'b1;
                    end
                    {`F3_SLL, `F7_SLL}: begin
                        alu_op = `ALU_SLL;
                        reg_write = 1'b1;
                    end
                    {`F3_SRL_SRA, `F7_SRL}: begin
                        alu_op = `ALU_SRL;
                        reg_write = 1'b1;
                    end
                    {`F3_SRL_SRA, `F7_SRA}: begin
                        alu_op = `ALU_SRA;
                        reg_write = 1'b1;
                    end
                    default: begin
                        alu_op = `ALU_PASS;
                        reg_write = 1'b0;
                    end
                endcase
            end

            `OPCODE_ITYPE: begin
                imm = {{20{instr[31]}}, instr[31:20]};
                op2_sel = `OP2_IMM;

                case (funct3)
                    `F3_ADD_SUB: begin
                        alu_op = `ALU_ADD;
                        reg_write = 1'b1;
                    end
                    `F3_SLL: begin
                        if(funct7 == `F7_SLL)begin
                            alu_op = `ALU_SLL;
                            reg_write = 1'b1;
                        end
                    end
                    `F3_SRL_SRA: begin
                        if (funct7 == `F7_SRA) begin
                            alu_op = `ALU_SRA;
                            reg_write = 1'b1;
                        end else if (funct7 == `F7_SRL) begin
                            alu_op = `ALU_SRL;
                            reg_write = 1'b1;
                        end
                    end
                    default: begin
                        alu_op = `ALU_PASS;
                        reg_write = 1'b0;
                    end
                endcase
            end

            `OPCODE_LOAD: begin
                if (funct3 == `F3_LW) begin
                    imm = {{20{instr[31]}}, instr[31:20]};
                    alu_op = `ALU_ADD;
                    op2_sel = `OP2_IMM;
                    wb_sel = `WB_MEM;
                    is_mem_read = 1'b1;
                    reg_write = 1'b1;
                end
            end

            `OPCODE_STORE: begin
                if (funct3 == `F3_SW) begin
                    imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                    alu_op = `ALU_ADD;
                    op2_sel = `OP2_IMM;
                    is_mem_write = 1'b1;
                    reg_write = 1'b0;
                end
            end

            `OPCODE_BRANCH: begin
                if (funct3 == `F3_BEQ) begin
                    imm = {{19{instr[31]}}, instr[31], instr[7],
                           instr[30:25], instr[11:8], 1'b0};
                    alu_op = `ALU_SUB;
                    branch_type = `BR_BEQ;
                    reg_write = 1'b0;
                end
            end

            `OPCODE_JAL: begin
                imm = {{11{instr[31]}}, instr[31], instr[19:12],
                       instr[20], instr[30:21], 1'b0};
                alu_op = `ALU_ADD;
                op1_sel = `OP1_PC;
                op2_sel = `OP2_IMM;
                wb_sel = `WB_PC4;
                branch_type = `BR_JAL;
                reg_write = 1'b1;
            end

            `OPCODE_JALR: begin
                if (funct3 == `F3_JALR) begin
                    imm = {{20{instr[31]}}, instr[31:20]};
                    alu_op = `ALU_ADD;
                    op2_sel = `OP2_IMM;
                    wb_sel = `WB_PC4;
                    branch_type = `BR_JALR;
                    reg_write = 1'b1;
                end
            end

            default: begin
                imm          = 32'h0;
                alu_op       = `ALU_PASS;
                op1_sel      = `OP1_RS1;
                op2_sel      = `OP2_RS2;
                wb_sel       = `WB_ALU;
                branch_type  = `BR_NONE;
                reg_write    = 1'b0;
                is_mem_read  = 1'b0;
                is_mem_write = 1'b0;
            end
        endcase
    end
endmodule
