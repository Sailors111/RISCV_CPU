// rtl/define.v


/*
    R-type:  add sub and or xor sll srl sra slt sltu
    I-type:  addi andi ori xori slli srli srai slti sltiu jalr
    Load/Store: lw sw
    Branch:  beq bne blt bge bltu bgeu
    Jump:    jal
    U-type:  lui auipc
*/


`ifndef DEFINE_V
`define DEFINE_V

// 1、操作码（opcode）
`define OPCODE_RTYPE  7'b0110011    // R型指令
`define OPCODE_ITYPE  7'b0010011    // I型指令
`define OPCODE_LOAD   7'b0000011    // load指令
`define OPCODE_STORE  7'b0100011    // store指令（S型指令）
`define OPCODE_BRANCH 7'b1100011    // B型指令
`define OPCODE_JAL    7'b1101111    // J型指令（PC = PC + offset），无条件跳转
`define OPCODE_JALR   7'b1100111    // J型指令（PC = [rs1] + offset），寄存器间接跳转
`define OPCODE_LUI    7'b0110111    // U型指令（lui指令：立即数高位加哉到rd）
`define OPCODE_AUIPC  7'b0010111    // U型指令（AUIPC指令：立即数高位加到PC）


// 2、3位功能码（funct3）
`define F3_ADD_SUB  3'b000  // 加法减法（靠Funct7区分）
`define F3_AND      3'b111  // 与操作
`define F3_OR       3'b110  // 或操作
`define F3_XOR      3'b100  // 异或操作

`define F3_SLL      3'b001  // 左移
`define F3_SRL_SRA  3'b101  // 右移（逻辑/算术靠Funct7区分）

`define F3_SLT      3'b010  // 有符号比较，rs1 < rs2则为1，否则为0
`define F3_SLTU     3'b011  // 无符号比较，rs1 < rs2则为1，否则为0

`define F3_BEQ      3'b000
`define F3_BNE      3'b001
`define F3_BLT      3'b100
`define F3_BGE      3'b101
`define F3_BLTU     3'b110
`define F3_BGEU     3'b111

`define F3_LB       3'b000  // 读字节并符号扩展
`define F3_LH       3'b001  // 读半字并符号扩展
`define F3_LW       3'b010  // 读字
`define F3_LBU      3'b100  // 读字节并零扩展
`define F3_LHU      3'b101  // 读半字并零扩展

`define F3_SB       3'b000  // 写字节
`define F3_SH       3'b001  // 写半字
`define F3_SW       3'b010  // 写字

`define F3_JALR     3'b000

// 3、7位功能码（funct7）
`define F7_ADD         7'b0000000
`define F7_SUB         7'b0100000
`define F7_AND         7'b0000000
`define F7_OR          7'b0000000
`define F7_XOR         7'b0000000

`define F7_SLL         7'b0000000
`define F7_SRL         7'b0000000
`define F7_SRA         7'b0100000

`define F7_SLT         7'b0000000
`define F7_SLTU        7'b0000000

// ALU操作码
`define ALU_ADD        5'b00000
`define ALU_SUB        5'b00001
`define ALU_AND        5'b00010
`define ALU_OR         5'b00011
`define ALU_XOR        5'b00111

`define ALU_SLL        5'b00100
`define ALU_SRL        5'b00101
`define ALU_SRA        5'b00110

`define ALU_SLT        5'b01000
`define ALU_SLTU       5'b01001

`define ALU_PASS       5'b11111

// EX阶段ALU第一个操作数来源
`define OP1_RS1        1'b0     // 第一操作数来自rs1
`define OP1_PC         1'b1     // 第一操作数来自PC

// EX阶段ALU第二个操作数来源
`define OP2_RS2        1'b0     // 第二操作数来自rs2
`define OP2_IMM        1'b1     // 第二操作数来自imm

// WB阶段选择写回寄存器的数据来源
`define WB_ALU         2'b00    // ALU写回
`define WB_MEM         2'b01    // 内存写回
`define WB_PC4         2'b10    // PC写回

// branch_type
`define BR_NONE    4'b0000
`define BR_BEQ     4'b0001
`define BR_BNE     4'b0010
`define BR_BLT     4'b0011
`define BR_BGE     4'b0100
`define BR_BLTU    4'b0101
`define BR_BGEU    4'b0110
`define BR_JAL     4'b0111
`define BR_JALR    4'b1000

// 数据冒险转发技术
`define NOT_FORWARD 2'b00   // 无需转发
`define FORWARD_EX  2'b01   // 从EX/MEM转发
`define FORWARD_MEM 2'b10   // 从MEM/WB转发


`endif 
