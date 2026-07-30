
module top (
    input clk,
    input rst_n,

    output wire [31:0] alu_result, 
    output wire [31:0] store_data, 
    output wire [31:0] pc_plus4,         

    output wire        branch_taken,    

    output wire [4:0]  rd_out,          
    output wire        reg_write_out,       
    output wire        is_mem_read_out,     
    output wire        is_mem_write_out,    
    output wire [1:0]  wb_sel_out          
);

    // 第1级：取指（IF）
    wire [31:0] if_pc;
    wire [31:0] if_instr;
    wire [31:0] if_pc_next;

    assign if_pc_next = if_pc + 32'd4;

    IF u_if(
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(if_pc_next),
        .pc(if_pc),
        .instr(if_instr)
    ); 

    // IF/ID 级间寄存器
    reg [31:0] if_id_pc;
    reg [31:0] if_id_instr;
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            if_id_pc    <= 32'h0;
            if_id_instr <= 32'h00000013;  // NOP
        end else begin
            if_id_pc    <= if_pc;
            if_id_instr <= if_instr;
        end
    end

    // 还未真的执行WB
    wire wb_reg_write;
    wire [4:0] wb_rd;
    wire [31:0] wb_wdata;

    assign wb_reg_write = 1'b0;
    assign wb_rd        = 5'd0;
    assign wb_wdata     = 32'h0;

    // 第2级：译码（ID）
    wire [31:0] id_pc;
    
    wire [4:0] id_rd;
    wire [4:0] id_rs1;
    wire [4:0] id_rs2;
    wire [31:0] id_imm;
    wire [4:0] id_alu_op;
    wire id_op1_sel;
    wire id_op2_sel;
    wire [1:0] id_wb_sel;
    wire [1:0] id_branch_type;
    wire id_reg_write;
    wire id_is_mem_read;
    wire id_is_mem_write;

    wire [31:0] id_rs1_data;
    wire [31:0] id_rs2_data;

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
        
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data)
    );
    
    // ID/EX 级间寄存器
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
    reg [1:0] id_ex_branch_type;
    reg id_ex_is_mem_read;
    reg id_ex_is_mem_write;
    reg id_ex_reg_write;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_ex_pc <= 32'h0;
            id_ex_rs1_data <= 32'h0;
            id_ex_rs2_data <= 32'h0;
            id_ex_imm <= 32'h0;
            id_ex_rd <= 5'h0;
            id_ex_rs1 <= 5'h0;
            id_ex_rs2 <= 5'h0;
            id_ex_alu_op <= 5'h0;
            id_ex_op1_sel <= 1'b0;
            id_ex_op2_sel <= 1'b0;
            id_ex_wb_sel <= 2'b0;
            id_ex_branch_type <= 2'b0;
            id_ex_is_mem_read <= 1'b0;
            id_ex_is_mem_write <= 1'b0;
            id_ex_reg_write <= 1'b0;
        end else begin
            id_ex_pc <= id_pc;
            id_ex_rs1_data <= id_rs1_data;
            id_ex_rs2_data <= id_rs2_data;
            id_ex_imm <= id_imm;
            id_ex_rd <= id_rd;
            id_ex_rs1 <= id_rs1;
            id_ex_rs2 <= id_rs2;
            id_ex_alu_op <= id_alu_op;
            id_ex_op1_sel <= id_op1_sel;
            id_ex_op2_sel <= id_op2_sel;
            id_ex_wb_sel <= id_wb_sel;
            id_ex_branch_type <= id_branch_type;
            id_ex_is_mem_read <= id_is_mem_read;
            id_ex_is_mem_write <= id_is_mem_write;
            id_ex_reg_write <= id_reg_write;
        end
    end

    // 第3级：执行（EX）
    wire [31:0] ex_alu_result;
    wire [31:0] ex_store_data;
    wire [31:0] ex_pc_plus4;
    wire [31:0] ex_pc_next;
    wire ex_branch_taken;
    wire [4:0] ex_rd;
    wire ex_reg_write;
    wire ex_is_mem_read;
    wire ex_is_mem_write;
    wire [1:0] ex_wb_sel;

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

        .id_rs1_data(id_ex_rs1_data),
        .id_rs2_data(id_ex_rs2_data),

        .alu_result(ex_alu_result),
        .store_data(ex_store_data),
        .pc_plus4(ex_pc_plus4),
        .pc_next(ex_pc_next),
        .branch_taken(ex_branch_taken),
        .rd(ex_rd),
        .reg_write(ex_reg_write),
        .is_mem_read(ex_is_mem_read),
        .is_mem_write(ex_is_mem_write),
        .wb_sel(ex_wb_sel)
    );

    // EX/MEM 级间寄存器
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_store_data;
    reg [31:0] ex_mem_pc_plus4;
    reg        ex_mem_branch_taken;
    reg [4:0]  ex_mem_rd;
    reg        ex_mem_reg_write;
    reg        ex_mem_is_mem_read;
    reg        ex_mem_is_mem_write;
    reg [1:0]  ex_mem_wb_sel;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_mem_alu_result   <= 32'h0;
            ex_mem_store_data   <= 32'h0;
            ex_mem_pc_plus4     <= 32'h0;
            ex_mem_branch_taken <= 1'b0;
            ex_mem_rd           <= 5'h0;
            ex_mem_reg_write    <= 1'b0;
            ex_mem_is_mem_read  <= 1'b0;
            ex_mem_is_mem_write <= 1'b0;
            ex_mem_wb_sel       <= 2'b0;
        end else begin
            ex_mem_alu_result   <= ex_alu_result;
            ex_mem_store_data   <= ex_store_data;
            ex_mem_pc_plus4     <= ex_pc_plus4;
            ex_mem_branch_taken <= ex_branch_taken;
            ex_mem_rd           <= ex_rd;
            ex_mem_reg_write    <= ex_reg_write;
            ex_mem_is_mem_read  <= ex_is_mem_read;
            ex_mem_is_mem_write <= ex_is_mem_write;
            ex_mem_wb_sel       <= ex_wb_sel;
        end
    end

    assign alu_result       = ex_mem_alu_result;
    assign store_data       = ex_mem_store_data;
    assign pc_plus4         = ex_mem_pc_plus4;
    assign branch_taken     = ex_mem_branch_taken;
    assign rd_out           = ex_mem_rd;
    assign reg_write_out    = ex_mem_reg_write;
    assign is_mem_read_out  = ex_mem_is_mem_read;
    assign is_mem_write_out = ex_mem_is_mem_write;
    assign wb_sel_out       = ex_mem_wb_sel;

    
endmodule
