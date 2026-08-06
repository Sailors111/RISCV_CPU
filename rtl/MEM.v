

module MEM(
    input wire clk,

    input wire [31:0] ex_alu_result,    // 对于运算指令，为运算结果；对于访存指令，为访存地址
    input wire [31:0] ex_store_data,    // sw指令的写回数据

    input wire ex_is_mem_read,          
    input wire ex_is_mem_write,

    input wire [4:0] ex_rd,             // WB阶段写回的目的寄存器编号
    input wire ex_reg_write,            // WB阶段写寄存器堆使能
    input wire [1:0] ex_wb_sel,         // WB阶段写寄存器堆数据来源：ALU/MEM/PC
    
    input wire [31:0] ex_pc_plus4,
    
    output wire [4:0] rd,
    output wire reg_write,
    output wire [1:0] wb_sel,

    output wire [31:0] pc_plus4,        // PC写回rd
    output wire [31:0] alu_result,      // ALU运算结果写回rd
    output wire [31:0] mem_data         // lw指令读内存结果写回rd
);

    wire [31:0] addr = ex_alu_result;
    wire [31:0] wdata = ex_store_data;
    wire [31:0] rdata;
    
    DCache u_dcache(
        .clk(clk),
        
        .is_mem_read(ex_is_mem_read),
        .is_mem_write(ex_is_mem_write),

        .addr(addr),
        .wdata(wdata),

        .rdata(rdata)
    );

    assign rd = ex_rd;
    assign reg_write = ex_reg_write;
    assign wb_sel = ex_wb_sel;
    assign pc_plus4 = ex_pc_plus4;
    assign alu_result = ex_alu_result;
    assign mem_data = rdata;

endmodule
