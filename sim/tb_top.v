`timescale 1ns/1ps

module tb_top;
    reg clk;
    reg rst_n;

    wire [31:0] if_id_pc_out;
    wire [31:0] if_id_instr_out;

    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [31:0] imm;
    wire [4:0] alu_op;
    wire op1_sel;
    wire op2_sel;
    wire [1:0] wb_sel;
    wire [1:0] branch_type;
    wire reg_write;
    wire is_mem_read;
    wire is_mem_write;
    wire [4:0] shamt;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    top u_top (
        .clk(clk),
        .rst_n(rst_n),

        .if_id_pc_out(if_id_pc_out),
        .if_id_instr_out(if_id_instr_out),

        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .imm(imm),
        .alu_op(alu_op),
        .op1_sel(op1_sel),
        .op2_sel(op2_sel),
        .wb_sel(wb_sel),
        .branch_type(branch_type),
        .reg_write(reg_write),
        .is_mem_read(is_mem_read),
        .is_mem_write(is_mem_write),
        .shamt(shamt),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    always #5 clk = ~clk;   // 时钟周期为10ns

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;

        #20;
        rst_n = 1'b1;

        #300;
        $finish;
    end

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end

    initial begin
        $display("time ifid_pc  ifid_ins idex_pc  rd rs1 rs2 imm      alu op1 op2 wb br reg mr mw shamt rs1_data rs2_data");
        $monitor("%4t %h %h %h %2d %3d %3d %h %05b  %b   %b  %02b %02b  %b  %b  %b  %2d  %h %h",
                 $time,
                 if_id_pc_out,
                 if_id_instr_out,
                 u_top.id_ex_pc,
                 rd,
                 rs1,
                 rs2,
                 imm,
                 alu_op,
                 op1_sel,
                 op2_sel,
                 wb_sel,
                 branch_type,
                 reg_write,
                 is_mem_read,
                 is_mem_write,
                 shamt,
                 rs1_data,
                 rs2_data);
    end
endmodule
