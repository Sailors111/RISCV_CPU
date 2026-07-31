`timescale 1ns/1ns

module tb_top;
    reg clk;
    reg rst_n;

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

    top u_top (
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

    always #5 clk = ~clk;   // 时钟周期为10ns

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;

        #20;
        rst_n = 1'b1;

        #400;
        $finish;
    end

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end

    integer cycle;

    initial begin
        cycle = -1;
    end

    always @(posedge clk) begin
        cycle = cycle + 1;
        #1;
        $display("------------------------------------------------------------");
        $display("cycle=C%0d", cycle);
        $display("time=%0t", $time);
        $display("IF   : pc=%h instr=%h", if_pc_out, if_instr_out);
        $display("IFID : pc=%h instr=%h", if_id_pc_out, if_id_instr_out);
        $display("IDEX : pc=%h", id_ex_pc_out);
        $display("EXMEM: alu_out=%h", ex_mem_alu_result_out);
        $display("MEMWB: alu_out=%h mem_out=%h", mem_wb_alu_result_out, mem_wb_mem_data_out);
        $display("WB   : rd=%0d we=%b wdata=%h", wb_rd_out, wb_reg_write_out, wb_wdata_out);
        $display("REG  : x0=%h x1=%h x2=%h x3=%h",
                 u_top.u_id.u_regfile.regs[0],
                 u_top.u_id.u_regfile.regs[1],
                 u_top.u_id.u_regfile.regs[2],
                 u_top.u_id.u_regfile.regs[3]);
        $display("REG  : x4=%h x5=%h x6=%h x7=%h",
                 u_top.u_id.u_regfile.regs[4],
                 u_top.u_id.u_regfile.regs[5],
                 u_top.u_id.u_regfile.regs[6],
                 u_top.u_id.u_regfile.regs[7]);
        $display("REG  : x8=%h x9=%h x10=%h x11=%h",
                 u_top.u_id.u_regfile.regs[8],
                 u_top.u_id.u_regfile.regs[9],
                 u_top.u_id.u_regfile.regs[10],
                 u_top.u_id.u_regfile.regs[11]);
        $display("DMEM : mem[0]=%h mem[1]=%h mem[2]=%h mem[3]=%h",
                 u_top.u_mem.u_data_ram.mem[0],
                 u_top.u_mem.u_data_ram.mem[1],
                 u_top.u_mem.u_data_ram.mem[2],
                 u_top.u_mem.u_data_ram.mem[3]);
    end

endmodule
