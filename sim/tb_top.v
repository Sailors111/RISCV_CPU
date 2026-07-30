`timescale 1ns/1ps

module tb_top;
    reg clk;
    reg rst_n;

    wire [31:0] alu_result;
    wire [31:0] store_data;
    wire [31:0] pc_plus4;
    wire [31:0] pc_next;
    wire        branch_taken;
    wire [4:0]  rd_out;
    wire        reg_write_out;
    wire        is_mem_read_out;
    wire        is_mem_write_out;
    wire [1:0]  wb_sel_out;

    top u_top (
        .clk(clk),
        .rst_n(rst_n),

        .alu_result(alu_result),
        .store_data(store_data),
        .pc_plus4(pc_plus4),
        .pc_next(pc_next),
        .branch_taken(branch_taken),
        .rd_out(rd_out),
        .reg_write_out(reg_write_out),
        .is_mem_read_out(is_mem_read_out),
        .is_mem_write_out(is_mem_write_out),
        .wb_sel_out(wb_sel_out)
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
        $display("time if_pc    if_instr ifid_pc  ifid_ins idex_pc  exmem_alu exmem_sd  pc4      pc_next  br rd reg mr mw wb");
        $monitor("%4t %h %h %h %h %h %h %h %h %h %b %2d  %b  %b  %b %02b",
                 $time,
                 u_top.if_pc,
                 u_top.if_instr,
                 u_top.if_id_pc,
                 u_top.if_id_instr,
                 u_top.id_ex_pc,
                 alu_result,
                 store_data,
                 pc_plus4,
                 pc_next,
                 branch_taken,
                 rd_out,
                 reg_write_out,
                 is_mem_read_out,
                 is_mem_write_out,
                 wb_sel_out);
    end
endmodule
