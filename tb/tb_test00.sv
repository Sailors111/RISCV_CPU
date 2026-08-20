`timescale 1ns/1ps

module tb_top;
    reg clk;
    reg rst_n;
    integer errors;

    wire [31:0] if_pc_out;
    wire [31:0] if_instr_out;
    wire [31:0] if_id_pc_out;
    wire [31:0] if_id_instr_out;
    wire [31:0] id_ex_pc_out;
    wire [31:0] ex_mem_alu_result_out;
    wire [31:0] mem_wb_alu_result_out;
    wire [31:0] mem_wb_mem_data_out;
    wire [4:0]  wb_rd_out;
    wire        wb_reg_write_out;
    wire [31:0] wb_wdata_out;

    top #(
        .PROGRAM_FILE("hex/test00.txt"),
        .PROGRAM_WORDS(24)
    ) u_top (
        .clk(clk),
        .rst_n(rst_n),
        .if_pc_out(if_pc_out),
        .if_instr_out(if_instr_out),
        .if_id_pc_out(if_id_pc_out),
        .if_id_instr_out(if_id_instr_out),
        .id_ex_pc_out(id_ex_pc_out),
        .ex_mem_alu_result_out(ex_mem_alu_result_out),
        .mem_wb_alu_result_out(mem_wb_alu_result_out),
        .mem_wb_mem_data_out(mem_wb_mem_data_out),
        .wb_rd_out(wb_rd_out),
        .wb_reg_write_out(wb_reg_write_out),
        .wb_wdata_out(wb_wdata_out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic check_reg(input integer index, input [31:0] expected);
        reg [31:0] got;
        begin
            got = u_top.u_id.u_regfile.regs[index];
            if (got !== expected) begin
                $display("[test00] x%0d expected 0x%08h, got 0x%08h", index, expected, got);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;
        rst_n = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (80) @(posedge clk);

        check_reg(1,  32'h00000005);
        check_reg(2,  32'h00000007);
        check_reg(3,  32'h0000000c);
        check_reg(4,  32'h00000002);
        check_reg(5,  32'h00000005);
        check_reg(6,  32'h00000007);
        check_reg(7,  32'h00000002);
        check_reg(8,  32'h00000280);
        check_reg(9,  32'h00000014);
        check_reg(11, 32'hfffffff0);
        check_reg(12, 32'h00000002);
        check_reg(13, 32'hfffffffc);
        check_reg(14, 32'h00000001);
        check_reg(15, 32'h00000000);
        check_reg(16, 32'h00000002);
        check_reg(17, 32'h00000003);
        check_reg(18, 32'h0000000d);
        check_reg(19, 32'h00000004);
        check_reg(20, 32'h00000028);
        check_reg(21, 32'h0000000a);
        check_reg(22, 32'hfffffffc);
        check_reg(23, 32'h00000001);
        check_reg(24, 32'h00000001);
        check_reg(27, 32'h00000001);

        if (errors == 0) begin
            $display("[test00] PASS");
        end else begin
            $display("[test00] FAIL: %0d error(s)", errors);
        end
        $finish;
    end
endmodule
