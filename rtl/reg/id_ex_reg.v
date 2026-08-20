`include "define.v"

module id_ex_reg(
    input wire clk,
    input wire rst_n,

    input wire flush,              // 清空ID/EX级间寄存器，向EX阶段插入bubble

    input wire [31:0] pc_in,
    input wire [31:0] rs1_data_in,
    input wire [31:0] rs2_data_in,
    input wire [31:0] imm_in,

    input wire [4:0] rd_in,
    input wire [4:0] rs1_in,
    input wire [4:0] rs2_in,

    input wire [4:0] alu_op_in,

    input wire op1_sel_in,
    input wire op2_sel_in,

    input wire [1:0] wb_sel_in,
    input wire [3:0] branch_type_in,

    input wire reg_write_in,
    input wire is_mem_read_in,
    input wire is_mem_write_in,
    input wire [2:0] mem_funct3_in,

    output wire [31:0] pc_out,
    output wire [31:0] rs1_data_out,
    output wire [31:0] rs2_data_out,
    output wire [31:0] imm_out,

    output wire [4:0] rd_out,
    output wire [4:0] rs1_out,
    output wire [4:0] rs2_out,

    output wire [4:0] alu_op_out,

    output wire op1_sel_out,
    output wire op2_sel_out,

    output wire [1:0] wb_sel_out,
    output wire [3:0] branch_type_out,

    output wire reg_write_out,
    output wire is_mem_read_out,
    output wire is_mem_write_out,
    output wire [2:0] mem_funct3_out
);

    localparam ZERO_WORD = 32'h0;
    localparam ZERO_REG = 5'h0;

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

    reg id_ex_reg_write;
    reg id_ex_is_mem_read;
    reg id_ex_is_mem_write;
    reg [2:0] id_ex_mem_funct3;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            id_ex_pc           <= ZERO_WORD;
            id_ex_rs1_data     <= ZERO_WORD;
            id_ex_rs2_data     <= ZERO_WORD;
            id_ex_imm          <= ZERO_WORD;
            id_ex_rd           <= ZERO_REG;
            id_ex_rs1          <= ZERO_REG;
            id_ex_rs2          <= ZERO_REG;
            id_ex_alu_op       <= `ALU_PASS;
            id_ex_op1_sel      <= `OP1_RS1;
            id_ex_op2_sel      <= `OP2_RS2;
            id_ex_wb_sel       <= `WB_ALU;
            id_ex_branch_type  <= `BR_NONE;
            id_ex_reg_write    <= 1'b0;
            id_ex_is_mem_read  <= 1'b0;
            id_ex_is_mem_write <= 1'b0;
            id_ex_mem_funct3   <= `F3_LW;
        end else if(flush) begin
            // 向 EX 插入 bubble
            id_ex_pc           <= ZERO_WORD;
            id_ex_rs1_data     <= ZERO_WORD;
            id_ex_rs2_data     <= ZERO_WORD;
            id_ex_imm          <= ZERO_WORD;
            id_ex_rd           <= ZERO_REG;
            id_ex_rs1          <= ZERO_REG;
            id_ex_rs2          <= ZERO_REG;
            id_ex_alu_op       <= `ALU_PASS;
            id_ex_op1_sel      <= `OP1_RS1;
            id_ex_op2_sel      <= `OP2_RS2;
            id_ex_wb_sel       <= `WB_ALU;
            id_ex_branch_type  <= `BR_NONE;
            id_ex_reg_write    <= 1'b0;
            id_ex_is_mem_read  <= 1'b0;
            id_ex_is_mem_write <= 1'b0;
            id_ex_mem_funct3   <= `F3_LW;
        end else begin
            id_ex_pc           <= pc_in;
            id_ex_rs1_data     <= rs1_data_in;
            id_ex_rs2_data     <= rs2_data_in;
            id_ex_imm          <= imm_in;
            id_ex_rd           <= rd_in;
            id_ex_rs1          <= rs1_in;
            id_ex_rs2          <= rs2_in;
            id_ex_alu_op       <= alu_op_in;
            id_ex_op1_sel      <= op1_sel_in;
            id_ex_op2_sel      <= op2_sel_in;
            id_ex_wb_sel       <= wb_sel_in;
            id_ex_branch_type  <= branch_type_in;
            id_ex_reg_write    <= reg_write_in;
            id_ex_is_mem_read  <= is_mem_read_in;
            id_ex_is_mem_write <= is_mem_write_in;
            id_ex_mem_funct3   <= mem_funct3_in;
        end
    end

    assign pc_out           = id_ex_pc;
    assign rs1_data_out     = id_ex_rs1_data;
    assign rs2_data_out     = id_ex_rs2_data;
    assign imm_out          = id_ex_imm;
    assign rd_out           = id_ex_rd;
    assign rs1_out          = id_ex_rs1;
    assign rs2_out          = id_ex_rs2;
    assign alu_op_out       = id_ex_alu_op;
    assign op1_sel_out      = id_ex_op1_sel;
    assign op2_sel_out      = id_ex_op2_sel;
    assign wb_sel_out       = id_ex_wb_sel;
    assign branch_type_out  = id_ex_branch_type;
    assign reg_write_out    = id_ex_reg_write;
    assign is_mem_read_out  = id_ex_is_mem_read;
    assign is_mem_write_out = id_ex_is_mem_write;
    assign mem_funct3_out   = id_ex_mem_funct3;

endmodule
