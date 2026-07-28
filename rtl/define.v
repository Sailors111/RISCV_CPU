// rtl/define.v

`ifndef DEFINE_V
`define DEFINE_V

// 1、操作码（opcode）
`define OPCODE_ADD  7'b0110011  // R型
`define OPCODE_ADDI 7'b0010011  // I型
`define OPCODE_LW   7'b0000011  // I型 (Load)
`define OPCODE_SW   7'b0100011  // S型 (Store)
`define OPCODE_BEQ  7'b1100011  // B型 (Branch)

// 2、3位功能码（funct3）
`define F3_ADD  3'b000
`define F3_SUB  3'b000  // 和 ADD 相同，靠 Funct7 区分
`define F3_AND  3'b111
`define F3_OR   3'b110
`define F3_XOR  3'b100
`define F3_BEQ  3'b000
`define F3_LW   3'b010
`define F3_SW   3'b010
`define F3_SLL  3'b001  // 左移
`define F3_SRL  3'b101  // 右移 (逻辑/算术靠Funct7区分)
`define F3_SRA  3'b101  // 和 SRL 的 Funct3 相同！

// 3、7位功能码（funct7）
`define F7_ADD  7'b0000000
`define F7_SUB  7'b0100000
`define F7_AND  7'b0000000
`define F7_OR   7'b0000000
`define F7_XOR  7'b0000000
`define F7_SLL  7'b0000000
`define F7_SRL  7'b0000000
`define F7_SRA  7'b0100000

// 生成17位唯一指令ID，格式：{opcode[6:0], funct3[2:0], funct7[6:0]}
`define INS_ID(op, f3, f7) {`op, `f3, `f7}

// 定义具体指令的ID
`define ID_ADD  `INS_ID(OPCODE_ADD, F3_ADD, F7_ADD)
`define ID_SUB  `INS_ID(OPCODE_ADD, F3_SUB, F7_SUB)
`define ID_AND  `INS_ID(OPCODE_ADD, F3_AND, F7_AND)
`define ID_OR   `INS_ID(OPCODE_ADD, F3_OR,  F7_OR)
`define ID_XOR  `INS_ID(OPCODE_ADD, F3_XOR, F7_XOR)
`define ID_ADDI `INS_ID(OPCODE_ADDI, F3_ADD, 7'b0)  // ADDI 没有 Funct7，填 0
`define ID_LW   `INS_ID(OPCODE_LW, F3_LW, 7'b0)
`define ID_SW   `INS_ID(OPCODE_SW, F3_SW, 7'b0)
`define ID_BEQ  `INS_ID(OPCODE_BEQ, F3_BEQ, 7'b0)
`define ID_SLL  `INS_ID(OPCODE_ADD, F3_SLL, F7_SLL)
`define ID_SRL  `INS_ID(OPCODE_ADD, F3_SRL, F7_SRL)
`define ID_SRA  `INS_ID(OPCODE_ADD, F3_SRA, F7_SRA)
`define ID_SLLI `INS_ID(OPCODE_ADDI, F3_SLL, 7'b0)  // shamt 在 instr[31:20]
`define ID_SRLI `INS_ID(OPCODE_ADDI, F3_SRL, 7'b0)  // 注意：需要检查 instr[30] 判断 SRLI/SRAI
`define ID_SRAI `INS_ID(OPCODE_ADDI, F3_SRA, 7'b0)  // 需要检查 instr[30]


// ALU操作码
// 基础运算 (00000 ~ 00011)
`define ALU_ADD  5'b00000
`define ALU_SUB  5'b00001
`define ALU_AND  5'b00010
`define ALU_OR   5'b00011
`define ALU_XOR  5'b00100
`define ALU_PASS 5'b11111  // 透传 (用于 LUI/AUIPC)

// 移位运算 (00100 ~ 00111)
`define ALU_SLL  5'b00100   // 逻辑左移
`define ALU_SRL  5'b00101   // 逻辑右移
`define ALU_SRA  5'b00110   // 算术右移


// 寄存器x0编号
`define REG_ZERO 5'd0 

`endif 
