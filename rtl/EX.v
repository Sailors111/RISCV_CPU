
`include "rtl/define.v"

module EX(
    // 来自ID/EX级间寄存器
    input wire [31:0] id_pc,

    // 来自ID段的信号
    input wire [4:0] id_rd,
    input wire [4:0] id_rs1,
    input wire [4:0] id_rs2,
    input wire [31:0] id_imm,
    input wire [4:0] id_alu_op,
    input wire id_op1_sel,
    input wire id_op2_sel,
    input wire [1:0] id_wb_sel,
    input wire [3:0] id_branch_type,
    input wire id_reg_write,
    input wire id_is_mem_read,
    input wire id_is_mem_write,
    input wire [2:0] id_mem_funct3,

    // 从寄存器堆读出的数据
    input wire [31:0] id_rs1_data,
    input wire [31:0] id_rs2_data,

    output wire [31:0] alu_result, /*
                                        ALU运算结果：
                                            add/sub/and/or/sll/srl/sra/addi/slli/srli/srai的运算结果
                                            lw/sw 的访存地址
                                    */
    output wire [31:0] store_data, // sw指令要写入内存的数据，一般是rs2_data
    output wire [31:0] pc_plus4,         // 用于jal/jalr指令写回rd

    output wire [31:0] pc_next,     // 下一条要送给PC的地址
    output wire        branch_taken,    // 当前指令是否触发跳转/分支指令

    output wire [4:0]  rd,          // 目的寄存器编号
    output wire        reg_write,       // 是否要写回寄存器堆
    output wire        is_mem_read,     // 是否要读内存
    output wire        is_mem_write,    // 是否要写内存
    output wire [2:0]  mem_funct3,      // 访存宽度/符号扩展控制
    output wire [1:0]  wb_sel          // WB阶段写回数据来源（ALU/mem/PC）
);

    wire [31:0] alu_in1;
    wire [31:0] alu_in2;
    wire [31:0] alu_out;

    wire [31:0] branch_target;
    wire [31:0] jalr_target;

    assign alu_in1 = (id_op1_sel == `OP1_RS1) ? id_rs1_data : id_pc;
    assign alu_in2 = (id_op2_sel == `OP2_RS2) ? id_rs2_data : id_imm;

    alu u_alu(
        .alu_op(id_alu_op),
        .op1(alu_in1),
        .op2(alu_in2),
        .result(alu_out)
    );

    assign alu_result = alu_out;
    assign store_data = id_rs2_data;

    assign pc_plus4 = id_pc + 32'd4;
    assign branch_target = id_pc + id_imm;
    assign jalr_target = (id_rs1_data + id_imm) & 32'hffff_fffe;

    assign branch_taken = 
        (id_branch_type == `BR_BEQ)  ? (id_rs1_data == id_rs2_data) :
        (id_branch_type == `BR_BNE)  ? (id_rs1_data != id_rs2_data) :
        (id_branch_type == `BR_BLT)  ? ($signed(id_rs1_data) < $signed(id_rs2_data)) :
        (id_branch_type == `BR_BGE)  ? ($signed(id_rs1_data) >= $signed(id_rs2_data)) :
        (id_branch_type == `BR_BLTU) ? (id_rs1_data < id_rs2_data) :
        (id_branch_type == `BR_BGEU) ? (id_rs1_data >= id_rs2_data) :
        (id_branch_type == `BR_JAL)  ? 1'b1 :
        (id_branch_type == `BR_JALR) ? 1'b1 :
                                    1'b0;

    wire is_branch = 
                    (id_branch_type == `BR_BEQ)  || 
                    (id_branch_type == `BR_BNE)  || 
                    (id_branch_type == `BR_BLT)  || 
                    (id_branch_type == `BR_BGE)  || 
                    (id_branch_type == `BR_BLTU) || 
                    (id_branch_type == `BR_BGEU);

    assign pc_next = 
        is_branch ? (branch_taken ? branch_target : pc_plus4) :
        (id_branch_type == `BR_JAL)  ? branch_target :
        (id_branch_type == `BR_JALR) ? jalr_target :
                                    pc_plus4;

    assign rd = id_rd;
    assign reg_write = id_reg_write;
    assign is_mem_read = id_is_mem_read;
    assign is_mem_write = id_is_mem_write;
    assign mem_funct3 = id_mem_funct3;
    assign wb_sel = id_wb_sel;
    
endmodule


