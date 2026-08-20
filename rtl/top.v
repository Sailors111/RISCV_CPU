
`include "define.v"


module top #(
    parameter PROGRAM_FILE = "hex/test00.txt",
    parameter PROGRAM_WORDS = 24
)(
    input clk,
    input rst_n,

    output wire [31:0] if_pc_out,
    output wire [31:0] if_instr_out,

    output wire [31:0] if_id_pc_out,
    output wire [31:0] if_id_instr_out,

    output wire [31:0] id_ex_pc_out,

    output wire [31:0] ex_mem_alu_result_out,
    output wire [31:0] mem_wb_alu_result_out,
    output wire [31:0] mem_wb_mem_data_out,

    output wire [4:0]  wb_rd_out,
    output wire        wb_reg_write_out,
    output wire [31:0] wb_wdata_out
);

    // 1. IF 阶段信号
    wire [31:0] if_pc;
    wire [31:0] if_instr;
    wire [31:0] if_pc_next;
    wire        if_pc_write;

    // 2. IF/ID 级间寄存器输出
    wire [31:0] if_id_pc;
    wire [31:0] if_id_instr;

    // 3. ID 阶段信号
    wire [31:0] id_pc;

    wire [4:0]  id_rd;
    wire [4:0]  id_rs1;
    wire [4:0]  id_rs2;

    wire [31:0] id_imm;
    wire [4:0]  id_alu_op;

    wire        id_op1_sel;
    wire        id_op2_sel;

    wire [1:0]  id_wb_sel;
    wire [3:0]  id_branch_type;

    wire        id_reg_write;
    wire        id_is_mem_read;
    wire        id_is_mem_write;
    wire [2:0]  id_mem_funct3;

    wire        id_use_rs1;
    wire        id_use_rs2;

    wire [31:0] id_rs1_data;
    wire [31:0] id_rs2_data;

    // 4. ID/EX 级间寄存器输出
    wire [31:0] id_ex_pc;
    wire [31:0] id_ex_rs1_data;
    wire [31:0] id_ex_rs2_data;
    wire [31:0] id_ex_imm;

    wire [4:0]  id_ex_rd;
    wire [4:0]  id_ex_rs1;
    wire [4:0]  id_ex_rs2;

    wire [4:0]  id_ex_alu_op;

    wire        id_ex_op1_sel;
    wire        id_ex_op2_sel;

    wire [1:0]  id_ex_wb_sel;
    wire [3:0]  id_ex_branch_type;

    wire        id_ex_reg_write;
    wire        id_ex_is_mem_read;
    wire        id_ex_is_mem_write;
    wire [2:0]  id_ex_mem_funct3;

    // 5. EX 阶段信号
    wire [31:0] ex_alu_result;
    wire [31:0] ex_store_data;
    wire [31:0] ex_pc_plus4;
    wire [31:0] ex_pc_next;

    wire        ex_branch_taken;

    wire [4:0]  ex_rd;
    wire        ex_reg_write;
    wire        ex_is_mem_read;
    wire        ex_is_mem_write;
    wire [1:0]  ex_wb_sel;
    wire [2:0]  ex_mem_funct3;

    // 6. EX/MEM 级间寄存器输出
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_store_data;
    wire [31:0] ex_mem_pc_plus4;

    wire [4:0]  ex_mem_rd;
    wire        ex_mem_reg_write;
    wire        ex_mem_is_mem_read;
    wire        ex_mem_is_mem_write;
    wire [1:0]  ex_mem_wb_sel;
    wire [2:0]  ex_mem_mem_funct3;

    // 7. MEM 阶段信号
    wire [4:0]  mem_rd;
    wire        mem_reg_write;
    wire [1:0]  mem_wb_sel;

    wire [31:0] mem_pc_plus4;
    wire [31:0] mem_alu_result;
    wire [31:0] mem_data;

    // 8. MEM/WB 级间寄存器输出
    wire [4:0]  mem_wb_rd;
    wire        mem_wb_reg_write;
    wire [1:0]  mem_wb_wb_sel;

    wire [31:0] mem_wb_alu_result;
    wire [31:0] mem_wb_mem_data;
    wire [31:0] mem_wb_pc_plus4;


    // 9. WB 阶段信号
    wire [4:0]  wb_rd;
    wire        wb_reg_write;
    wire [31:0] wb_wdata;


    // 10. load-use 冒险控制信号
    wire load_pc_write;
    wire load_if_id_write;
    wire load_id_ex_flush;


    // 11. 控制冒险信号
    wire control_flush;
    wire final_id_ex_flush;

    // 12. forwarding 信号
    wire [1:0] forward_rs1;
    wire [1:0] forward_rs2;

    wire [31:0] ex_mem_forward_data;
    wire [31:0] mem_wb_forward_data;

    wire [31:0] real_rs1_data;
    wire [31:0] real_rs2_data;



    // 第1级：取指（IF）
    assign if_pc_next = ex_branch_taken ? ex_pc_next : (if_pc + 32'd4);

    IF #(
        .PROGRAM_FILE(PROGRAM_FILE),
        .PROGRAM_WORDS(PROGRAM_WORDS)
    ) u_if(
        .clk(clk),
        .rst_n(rst_n),
        .pc_write(if_pc_write),
        .pc_next(if_pc_next),
        .pc(if_pc),
        .instr(if_instr)
    ); 

    // IF/ID 级间寄存器
    if_id_reg u_if_id_reg(
        .clk(clk),
        .rst_n(rst_n),

        .write_enable(load_if_id_write),
        .flush(control_flush),

        .pc_in(if_pc),
        .instr_in(if_instr),

        .pc_out(if_id_pc),
        .instr_out(if_id_instr)
    );

    // 第2级：译码（ID）
    ID u_id(
        .clk(clk),

        .if_pc(if_id_pc),
        .if_instr(if_id_instr),

        .wb_reg_write(wb_reg_write),
        .wb_rd(wb_rd),
        .wb_wdata(wb_wdata),

        .pc(id_pc),

        .rd(id_rd),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .imm(id_imm),
        .alu_op(id_alu_op),
        .op1_sel(id_op1_sel),
        .op2_sel(id_op2_sel),
        .wb_sel(id_wb_sel),
        .branch_type(id_branch_type),
        .reg_write(id_reg_write),
        .is_mem_read(id_is_mem_read),
        .is_mem_write(id_is_mem_write),
        .mem_funct3(id_mem_funct3),
        
        .use_rs1(id_use_rs1),
        .use_rs2(id_use_rs2),

        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data)
    );
    
    // ID/EX 级间寄存器
    id_ex_reg u_id_ex_reg(
        .clk(clk),
        .rst_n(rst_n),

        .flush(final_id_ex_flush),

        .pc_in(id_pc),
        .rs1_data_in(id_rs1_data),
        .rs2_data_in(id_rs2_data),
        .imm_in(id_imm),

        .rd_in(id_rd),
        .rs1_in(id_rs1),
        .rs2_in(id_rs2),
        .alu_op_in(id_alu_op),
        .op1_sel_in(id_op1_sel),
        .op2_sel_in(id_op2_sel),
        .wb_sel_in(id_wb_sel),
        .branch_type_in(id_branch_type),
        .reg_write_in(id_reg_write),
        .is_mem_read_in(id_is_mem_read),
        .is_mem_write_in(id_is_mem_write),
        .mem_funct3_in(id_mem_funct3),

        .pc_out(id_ex_pc),
        .rs1_data_out(id_ex_rs1_data),
        .rs2_data_out(id_ex_rs2_data),
        .imm_out(id_ex_imm),

        .rd_out(id_ex_rd),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .alu_op_out(id_ex_alu_op),
        .op1_sel_out(id_ex_op1_sel),
        .op2_sel_out(id_ex_op2_sel),
        .wb_sel_out(id_ex_wb_sel),
        .branch_type_out(id_ex_branch_type),
        .reg_write_out(id_ex_reg_write),
        .is_mem_read_out(id_ex_is_mem_read),
        .is_mem_write_out(id_ex_is_mem_write),
        .mem_funct3_out(id_ex_mem_funct3)
    );

    // 数据冒险：load-use解决方法

    hazard_unit u_hazard_unit(
        .id_ex_is_mem_read(id_ex_is_mem_read),
        .id_ex_rd(id_ex_rd),

        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_use_rs1(id_use_rs1),
        .id_use_rs2(id_use_rs2),

        .pc_write(load_pc_write),
        .if_id_write(load_if_id_write),
        .id_ex_flush(load_id_ex_flush)
    );

    assign control_flush = ex_branch_taken;

    assign if_pc_write = control_flush || load_pc_write;

    assign final_id_ex_flush = control_flush || load_id_ex_flush;

    // 第3级：执行（EX）

    assign ex_mem_forward_data =(ex_mem_wb_sel == `WB_PC4) ? ex_mem_pc_plus4 :
                                 ex_mem_alu_result;
    assign mem_wb_forward_data = wb_wdata;

    assign real_rs1_data =
        (forward_rs1 == `FORWARD_EX) ? ex_mem_forward_data :
        (forward_rs1 == `FORWARD_MEM) ? mem_wb_forward_data :
                            id_ex_rs1_data;

    assign real_rs2_data =
        (forward_rs2 == `FORWARD_EX) ? ex_mem_forward_data :
        (forward_rs2 == `FORWARD_MEM) ? mem_wb_forward_data :
                            id_ex_rs2_data;


    EX u_ex(
        .id_pc(id_ex_pc),

        .id_rd(id_ex_rd),
        .id_rs1(id_ex_rs1),
        .id_rs2(id_ex_rs2),
        .id_imm(id_ex_imm),
        .id_alu_op(id_ex_alu_op),
        .id_op1_sel(id_ex_op1_sel),
        .id_op2_sel(id_ex_op2_sel),
        .id_wb_sel(id_ex_wb_sel),
        .id_branch_type(id_ex_branch_type),
        .id_reg_write(id_ex_reg_write),
        .id_is_mem_read(id_ex_is_mem_read),
        .id_is_mem_write(id_ex_is_mem_write),
        .id_mem_funct3(id_ex_mem_funct3),

        .id_rs1_data(real_rs1_data),
        .id_rs2_data(real_rs2_data),

        .alu_result(ex_alu_result),
        .store_data(ex_store_data),
        .pc_plus4(ex_pc_plus4),
        .pc_next(ex_pc_next),

        .branch_taken(ex_branch_taken),
        .rd(ex_rd),
        .reg_write(ex_reg_write),
        .is_mem_read(ex_is_mem_read),
        .is_mem_write(ex_is_mem_write),
        .mem_funct3(ex_mem_funct3),
        .wb_sel(ex_wb_sel)
    );

    // EX/MEM 级间寄存器
    ex_mem_reg u_ex_mem_reg(
        .clk(clk),
        .rst_n(rst_n),

        .alu_result_in(ex_alu_result),
        .store_data_in(ex_store_data),
        .pc_plus4_in(ex_pc_plus4),
        .rd_in(ex_rd),
        .reg_write_in(ex_reg_write),
        .is_mem_read_in(ex_is_mem_read),
        .is_mem_write_in(ex_is_mem_write),
        .wb_sel_in(ex_wb_sel),
        .mem_funct3_in(ex_mem_funct3),

        .alu_result_out(ex_mem_alu_result),
        .store_data_out(ex_mem_store_data),
        .pc_plus4_out(ex_mem_pc_plus4),
        .rd_out(ex_mem_rd),
        .reg_write_out(ex_mem_reg_write),
        .is_mem_read_out(ex_mem_is_mem_read),
        .is_mem_write_out(ex_mem_is_mem_write),
        .wb_sel_out(ex_mem_wb_sel),
        .mem_funct3_out(ex_mem_mem_funct3)
    );


    // 第4级：访存（MEM）

    MEM u_mem(
        .clk(clk),

        .ex_alu_result(ex_mem_alu_result),
        .ex_store_data(ex_mem_store_data),

        .ex_is_mem_read(ex_mem_is_mem_read),
        .ex_is_mem_write(ex_mem_is_mem_write),
        .ex_mem_funct3(ex_mem_mem_funct3),

        .ex_rd(ex_mem_rd),
        .ex_reg_write(ex_mem_reg_write),
        .ex_wb_sel(ex_mem_wb_sel),
        .ex_pc_plus4(ex_mem_pc_plus4),

        .rd(mem_rd),
        .reg_write(mem_reg_write),
        .wb_sel(mem_wb_sel),
        .pc_plus4(mem_pc_plus4),
        .alu_result(mem_alu_result),
        .mem_data(mem_data)
    );

    // MEM/WB 级间寄存器
    mem_wb_reg u_mem_wb_reg(
        .clk(clk),
        .rst_n(rst_n),

        .rd_in(mem_rd),
        .reg_write_in(mem_reg_write),
        .wb_sel_in(mem_wb_sel),
        .alu_result_in(mem_alu_result),
        .mem_data_in(mem_data),
        .pc_plus4_in(mem_pc_plus4),

        .rd_out(mem_wb_rd),
        .reg_write_out(mem_wb_reg_write),
        .wb_sel_out(mem_wb_wb_sel),
        .alu_result_out(mem_wb_alu_result),
        .mem_data_out(mem_wb_mem_data),
        .pc_plus4_out(mem_wb_pc_plus4)
    );

    // 第5级：写回（WB）
    WB u_wb(
        .clk(clk),

        .mem_rd(mem_wb_rd),
        .mem_reg_write(mem_wb_reg_write),
        .mem_wb_sel(mem_wb_wb_sel),

        .mem_alu_result(mem_wb_alu_result),
        .mem_data(mem_wb_mem_data),
        .mem_pc_plus4(mem_wb_pc_plus4),

        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),
        .wb_wdata(wb_wdata)
    );

    // 数据冒险：旁路转发技术

    forwarding_unit u_forwarding_unit(
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),

        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_is_mem_read(ex_mem_is_mem_read),

        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),

        .forward_rs1(forward_rs1),
        .forward_rs2(forward_rs2)
    );

    // debug output
    assign if_pc_out              = if_pc;
    assign if_instr_out           = if_instr;

    assign if_id_pc_out           = if_id_pc;
    assign if_id_instr_out        = if_id_instr;

    assign id_ex_pc_out           = id_ex_pc;

    assign ex_mem_alu_result_out  = ex_mem_alu_result;
    assign mem_wb_alu_result_out  = mem_wb_alu_result;
    assign mem_wb_mem_data_out    = mem_wb_mem_data;

    assign wb_rd_out              = wb_rd;
    assign wb_reg_write_out       = wb_reg_write;
    assign wb_wdata_out           = wb_wdata;


endmodule
