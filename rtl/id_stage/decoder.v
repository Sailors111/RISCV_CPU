
`include "define.v"

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
    output reg [3:0] branch_type, // 分支/跳转类型
    output reg reg_write,       // 寄存器写使能
    output reg is_mem_read,     // 内存读使能
    output reg is_mem_write,    // 内存写使能
    output reg [2:0] mem_funct3, // 访存宽度/符号扩展控制

    output reg use_rs1,         // 是否使用rs1
    output reg use_rs2          // 是否使用rs2
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
        mem_funct3 = `F3_LW;
        use_rs1 = 1'b0;
        use_rs2 = 1'b0;

        // 指令译码
        case (opcode)
            `OPCODE_RTYPE: begin
                case ({funct3, funct7})
                    {`F3_ADD_SUB, `F7_ADD}: begin
                        alu_op = `ALU_ADD;          // add rd, rs1, rs2     [rd] = [rs1] + [rs2]
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    {`F3_ADD_SUB, `F7_SUB}: begin
                        alu_op = `ALU_SUB;          // sub rd, rs1, rs2     [rd] = [rs1] - [rs2]
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    {`F3_AND, `F7_AND}: begin
                        alu_op = `ALU_AND;          // and rd, rs1, rs2     [rd] = [rs1] & [rs2]
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    {`F3_OR, `F7_OR}: begin
                        alu_op = `ALU_OR;           // or rd, rs1, rs2      [rd] = [rs1] | [rs2]
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    {`F3_XOR, `F7_XOR}: begin
                        alu_op = `ALU_XOR;          // xor rd, rs1, rs2     [rd] = [rs1] ^ [rs2]
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    {`F3_SLL, `F7_SLL}: begin
                        alu_op = `ALU_SLL;          // sll rd, rs1, rs2     [rd] = [rs1] << [rs2][4:0]
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    {`F3_SRL_SRA, `F7_SRL}: begin
                        alu_op = `ALU_SRL;          // srl rd, rs1, rs2     [rd] = [rs1] >> [rs2][4:0]
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    {`F3_SRL_SRA, `F7_SRA}: begin
                        alu_op = `ALU_SRA;          // sra rd, rs1, rs2     [rd] = [rs1] >>> [rs2][4:0]
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    {`F3_SLT, `F7_SLT}: begin
                        alu_op = `ALU_SLT;          // slt rd, rs1, rs2     [rd] = ($signed([rs1]) < $signed([rs2])) ? 1 : 0
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    {`F3_SLTU, `F7_SLTU}: begin
                        alu_op = `ALU_SLTU;         // sltu rd, rs1, rs2    [rd] = ([rs1] < [rs2]) ? 1 : 0
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    default: begin
                        alu_op = `ALU_PASS;
                        reg_write = 1'b0;
                        use_rs1 = 1'b0;
                        use_rs2 = 1'b0;
                    end
                endcase
            end

            `OPCODE_ITYPE: begin
                imm = {{20{instr[31]}}, instr[31:20]};
                op2_sel = `OP2_IMM;

                case (funct3)
                    `F3_ADD_SUB: begin
                        alu_op = `ALU_ADD;          // addi rd, rs1, imm    [rd] = [rs1] + imm
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b0;
                    end
                    `F3_AND: begin
                        alu_op = `ALU_AND;          // andi rd, rs1, imm    [rd] = [rs1] & imm
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b0;
                    end
                    `F3_OR: begin
                        alu_op = `ALU_OR;           // ori rd, rs1, imm     [rd] = [rs1] | imm
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b0;
                    end
                    `F3_XOR: begin
                        alu_op = `ALU_XOR;          // xori rd, rs1, imm    [rd] = [rs1] ^ imm
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b0;
                    end
                    `F3_SLL: begin
                        if(funct7 == `F7_SLL) begin
                            alu_op = `ALU_SLL;      // slli rd, rs1, shamt  [rd] = [rs1] << shamt
                            reg_write = 1'b1;
                            use_rs1 = 1'b1;
                            use_rs2 = 1'b0;
                        end
                    end
                    `F3_SRL_SRA: begin
                        if (funct7 == `F7_SRA) begin
                            alu_op = `ALU_SRA;      // srai rd, rs1, shamt  [rd] = $signed([rs1]) >>> shamt
                            reg_write = 1'b1;
                            use_rs1 = 1'b1;
                            use_rs2 = 1'b0;
                        end else if (funct7 == `F7_SRL) begin
                            alu_op = `ALU_SRL;      // srli rd, rs1, shamt  [rd] = [rs1] >> shamt
                            reg_write = 1'b1;
                            use_rs1 = 1'b1;
                            use_rs2 = 1'b0;
                        end
                    end
                    `F3_SLT: begin
                        alu_op = `ALU_SLT;          // slti rd, rs1, imm    [rd] = ($signed([rs1]) < $signed(imm)) ? 1 : 0
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b0;
                    end
                    `F3_SLTU: begin
                        alu_op = `ALU_SLTU;         // sltiu rd, rs1, imm   [rd] = ([rs1] < imm) ? 1 : 0
                        reg_write = 1'b1;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b0;
                    end
                    default: begin
                        alu_op = `ALU_PASS;
                        reg_write = 1'b0;
                        use_rs1 = 1'b0;
                        use_rs2 = 1'b0;
                    end
                endcase
            end

            `OPCODE_LOAD: begin
                imm = {{20{instr[31]}}, instr[31:20]};
                alu_op = `ALU_ADD;
                op2_sel = `OP2_IMM;
                wb_sel = `WB_MEM;
                mem_funct3 = funct3;
                use_rs1 = 1'b1;
                use_rs2 = 1'b0;

                case(funct3)
                    `F3_LB: begin
                        is_mem_read = 1'b1;     // lb rd, imm(rs1)     [rd] = SignExt(Mem[[rs1] + imm][7:0])
                        reg_write = 1'b1;
                    end
                    `F3_LH: begin
                        is_mem_read = 1'b1;     // lh rd, imm(rs1)     [rd] = SignExt(Mem[[rs1] + imm][15:0])
                        reg_write = 1'b1;
                    end
                    `F3_LW: begin
                        is_mem_read = 1'b1;     // lw rd, imm(rs1)     [rd] = Mem[[rs1] + imm][31:0]
                        reg_write = 1'b1;
                    end
                    `F3_LBU: begin
                        is_mem_read = 1'b1;     // lbu rd, imm(rs1)    [rd] = ZeroExt(Mem[[rs1] + imm][7:0])
                        reg_write = 1'b1;
                    end
                    `F3_LHU: begin
                        is_mem_read = 1'b1;     // lhu rd, imm(rs1)    [rd] = ZeroExt(Mem[[rs1] + imm][15:0])
                        reg_write = 1'b1;
                    end
                    default: begin
                        is_mem_read = 1'b0;
                        reg_write = 1'b0;
                    end
                endcase
            end

            `OPCODE_STORE: begin
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                alu_op = `ALU_ADD;
                op2_sel = `OP2_IMM;
                mem_funct3 = funct3;
                reg_write = 1'b0;
                use_rs1 = 1'b1;
                use_rs2 = 1'b1;

                case(funct3)
                    `F3_SB: begin
                        is_mem_write = 1'b1;    // sb rs2, imm(rs1)    Mem[[rs1] + imm][7:0] = [rs2][7:0]
                    end
                    `F3_SH: begin
                        is_mem_write = 1'b1;    // sh rs2, imm(rs1)    Mem[[rs1] + imm][15:0] = [rs2][15:0]
                    end
                    `F3_SW: begin
                        is_mem_write = 1'b1;    // sw rs2, imm(rs1)    Mem[[rs1] + imm][31:0] = [rs2]
                    end
                    default: begin
                        is_mem_write = 1'b0;
                    end
                endcase
            end

            `OPCODE_BRANCH: begin
                case(funct3)
                    `F3_BEQ: begin
                        imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                        alu_op = `ALU_SUB;      // beq rs1, rs2, imm   if([rs1] == [rs2]) PC = PC + imm
                        branch_type = `BR_BEQ;
                        reg_write = 1'b0;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    `F3_BNE: begin
                        imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                        alu_op = `ALU_SUB;      // bne rs1, rs2, imm   if([rs1] != [rs2]) PC = PC + imm
                        branch_type = `BR_BNE;
                        reg_write = 1'b0;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    `F3_BLT: begin
                        imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                        alu_op = `ALU_SUB;      // blt rs1, rs2, imm   if($signed([rs1]) < $signed([rs2])) PC = PC + imm
                        branch_type = `BR_BLT;
                        reg_write = 1'b0;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    `F3_BGE: begin
                        imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                        alu_op = `ALU_SUB;      // bge rs1, rs2, imm   if($signed([rs1]) >= $signed([rs2])) PC = PC + imm
                        branch_type = `BR_BGE;
                        reg_write = 1'b0;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    `F3_BLTU: begin
                        imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                        alu_op = `ALU_SUB;      // bltu rs1, rs2, imm  if([rs1] < [rs2]) PC = PC + imm
                        branch_type = `BR_BLTU;
                        reg_write = 1'b0;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    `F3_BGEU: begin
                        imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                        alu_op = `ALU_SUB;      // bgeu rs1, rs2, imm  if([rs1] >= [rs2]) PC = PC + imm
                        branch_type = `BR_BGEU;
                        reg_write = 1'b0;
                        use_rs1 = 1'b1;
                        use_rs2 = 1'b1;
                    end
                    default: begin
                        imm = 32'h0;
                        alu_op = `ALU_PASS;
                        branch_type = `BR_NONE;
                        reg_write = 1'b0;
                        use_rs1 = 1'b0;
                        use_rs2 = 1'b0;
                    end
                endcase
            end

            `OPCODE_JAL: begin
                imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
                alu_op = `ALU_ADD;              // jal rd, imm         [rd] = PC + 4; PC = PC + imm
                op1_sel = `OP1_PC;
                op2_sel = `OP2_IMM;
                wb_sel = `WB_PC4;
                branch_type = `BR_JAL;
                reg_write = 1'b1;
            end

            `OPCODE_JALR: begin
                if (funct3 == `F3_JALR) begin
                    imm = {{20{instr[31]}}, instr[31:20]};
                    alu_op = `ALU_ADD;          // jalr rd, imm(rs1)   [rd] = PC + 4; PC = ([rs1] + imm) & ~1
                    op2_sel = `OP2_IMM;
                    wb_sel = `WB_PC4;
                    branch_type = `BR_JALR;
                    reg_write = 1'b1;
                    use_rs1 = 1'b1;
                    use_rs2 = 1'b0;
                end
            end

            `OPCODE_LUI: begin
                imm = {instr[31:12], 12'h0};
                op2_sel = `OP2_IMM;             // lui rd, imm         [rd] = imm << 12
                reg_write = 1'b1;
            end

            `OPCODE_AUIPC: begin
                imm = {instr[31:12], 12'h0};
                alu_op = `ALU_ADD;              // auipc rd, imm       [rd] = PC + (imm << 12)
                op1_sel = `OP1_PC;
                op2_sel = `OP2_IMM;
                reg_write = 1'b1;
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
                mem_funct3   = `F3_LW;
                use_rs1 = 1'b0;
                use_rs2 = 1'b0;
            end
        endcase
    end
endmodule
