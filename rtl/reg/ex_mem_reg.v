`include "define.v"

module ex_mem_reg(
    input wire clk,
    input wire rst_n,

    input wire [31:0] alu_result_in,
    input wire [31:0] store_data_in,
    input wire [31:0] pc_plus4_in,

    input wire [4:0] rd_in,
    input wire reg_write_in,
    input wire is_mem_read_in,
    input wire is_mem_write_in,
    input wire [1:0] wb_sel_in,
    input wire [2:0] mem_funct3_in,

    output wire [31:0] alu_result_out,
    output wire [31:0] store_data_out,
    output wire [31:0] pc_plus4_out,

    output wire [4:0] rd_out,
    output wire reg_write_out,
    output wire is_mem_read_out,
    output wire is_mem_write_out,
    output wire [1:0] wb_sel_out,
    output wire [2:0] mem_funct3_out
);

    localparam ZERO_WORD = 32'h0;
    localparam ZERO_REG = 5'h0;

    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_store_data;
    reg [31:0] ex_mem_pc_plus4;

    reg [4:0] ex_mem_rd;
    reg ex_mem_reg_write;
    reg ex_mem_is_mem_read;
    reg ex_mem_is_mem_write;
    reg [1:0] ex_mem_wb_sel;
    reg [2:0] ex_mem_mem_funct3;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ex_mem_alu_result   <= ZERO_WORD;
            ex_mem_store_data   <= ZERO_WORD;
            ex_mem_pc_plus4     <= ZERO_WORD;
            ex_mem_rd           <= ZERO_REG;
            ex_mem_reg_write    <= 1'b0;
            ex_mem_is_mem_read  <= 1'b0;
            ex_mem_is_mem_write <= 1'b0;
            ex_mem_wb_sel       <= `WB_ALU;
            ex_mem_mem_funct3   <= `F3_LW;
        end else begin
            ex_mem_alu_result   <= alu_result_in;
            ex_mem_store_data   <= store_data_in;
            ex_mem_pc_plus4     <= pc_plus4_in;
            ex_mem_rd           <= rd_in;
            ex_mem_reg_write    <= reg_write_in;
            ex_mem_is_mem_read  <= is_mem_read_in;
            ex_mem_is_mem_write <= is_mem_write_in;
            ex_mem_wb_sel       <= wb_sel_in;
            ex_mem_mem_funct3   <= mem_funct3_in;
        end
    end

    assign alu_result_out   = ex_mem_alu_result;
    assign store_data_out   = ex_mem_store_data;
    assign pc_plus4_out     = ex_mem_pc_plus4;
    assign rd_out           = ex_mem_rd;
    assign reg_write_out    = ex_mem_reg_write;
    assign is_mem_read_out  = ex_mem_is_mem_read;
    assign is_mem_write_out = ex_mem_is_mem_write;
    assign wb_sel_out       = ex_mem_wb_sel;
    assign mem_funct3_out   = ex_mem_mem_funct3;

endmodule
