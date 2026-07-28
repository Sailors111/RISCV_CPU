
module top (
    input clk,
    input rst_n,
    output reg [6:0] opcode,    // 操作码
    output reg [4:0] rd,        // 目标寄存器编号
    output reg [4:0] rs1,       // 源寄存器编号1
    output reg [4:0] rs2,       // 源寄存器2
    output reg [2:0] funct3     // 功能码3位
    output reg [6:0] funct7,    // 功能码7位
    output reg [31:0] imm       // 立即数（扩展后）
    output reg [4:0] alu_op,    // ALU操作码
    output reg reg_write,
    output reg is_branch,
    output reg is_mem_read,
    output reg is_mem_write,
    output reg [4:0] shamt      // 移位位数
);

    // 第1级：取指（IF）
    wire [31:0] pc_wire;
    wire [31:0] pc_next = pc_wire + 32'd4;
    wire [31:0] rom_instr;

    IF u_if(
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(pc_wire),
        .instr(rom_instr)
    ); 

    // IF/ID 级间寄存器
    reg [31:0] if_id_pc, if_id_instr;
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            if_id_pc <= 32'h0;
            if_id_instr <= 32'h00000013;  // NOP
        end else begin
            if_id_pc <= pc_wire;
            if_id_instr <= rom_instr;
        end
    end

    assign pc_out = if_id_pc;
    assign instr_out = if_id_instr;
    
endmodule

