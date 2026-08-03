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

    integer cycle;
    integer errors;

    reg        stall_at_edge;
    reg        wb_we_at_edge;
    reg [4:0]  wb_rd_at_edge;
    reg [31:0] wb_data_at_edge;
    reg        store_at_edge;
    reg [31:0] store_addr_at_edge;
    reg [31:0] store_data_at_edge;

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

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        cycle = 0;
        errors = 0;

        #20;
        rst_n = 1'b1;

        repeat (35) @(posedge clk);
        #1;
        print_final_state;
        $finish;
    end

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end

    // Sample commit events before pipeline registers update at the clock edge.
    always @(posedge clk) begin
        stall_at_edge     = u_top.id_ex_flush;
        wb_we_at_edge     = wb_reg_write_out;
        wb_rd_at_edge     = wb_rd_out;
        wb_data_at_edge   = wb_wdata_out;
        store_at_edge     = u_top.ex_mem_is_mem_write;
        store_addr_at_edge = u_top.ex_mem_alu_result;
        store_data_at_edge = u_top.ex_mem_store_data;

        #1;
        if (rst_n) begin
            cycle = cycle + 1;
            $display("C%02d PC=%08h IF_INSTR=%08h | IFID_PC=%08h IFID=%08h | IDEX_PC=%08h | STALL=%b FORWARD_RS1=%b FORWARD_RS2=%b",
                     cycle,
                     if_pc_out,
                     if_instr_out,
                     if_id_pc_out,
                     if_id_instr_out,
                     id_ex_pc_out,
                     stall_at_edge,
                     u_top.forward_rs1,
                     u_top.forward_rs2);

            if (stall_at_edge) begin
                $display("    STALL : load-use detected, PC/IFID held and ID/EX bubbled");
            end

            if (wb_we_at_edge) begin
                $display("    WB    : x%0d <= %08h", wb_rd_at_edge, wb_data_at_edge);
            end

            if (store_at_edge) begin
                $display("    STORE : mem[%0d] <= %08h (addr=%08h)",
                         store_addr_at_edge[31:2],
                         store_data_at_edge,
                         store_addr_at_edge);
            end
        end
    end

    task print_final_state;
        begin
            $display("============================================================");
            $display("FINAL REGISTER STATE");
            $display("x1 =%08h x2 =%08h x3 =%08h x4 =%08h",
                     u_top.u_id.u_regfile.regs[1],
                     u_top.u_id.u_regfile.regs[2],
                     u_top.u_id.u_regfile.regs[3],
                     u_top.u_id.u_regfile.regs[4]);
            $display("x5 =%08h x6 =%08h x7 =%08h x8 =%08h",
                     u_top.u_id.u_regfile.regs[5],
                     u_top.u_id.u_regfile.regs[6],
                     u_top.u_id.u_regfile.regs[7],
                     u_top.u_id.u_regfile.regs[8]);
            $display("x9 =%08h x10=%08h x11=%08h x12=%08h",
                     u_top.u_id.u_regfile.regs[9],
                     u_top.u_id.u_regfile.regs[10],
                     u_top.u_id.u_regfile.regs[11],
                     u_top.u_id.u_regfile.regs[12]);
            $display("FINAL MEMORY STATE");
            $display("mem[0]=%08h mem[1]=%08h mem[2]=%08h mem[3]=%08h",
                     u_top.u_mem.u_data_ram.mem[0],
                     u_top.u_mem.u_data_ram.mem[1],
                     u_top.u_mem.u_data_ram.mem[2],
                     u_top.u_mem.u_data_ram.mem[3]);
            $display("============================================================");
        end
    endtask

endmodule
