`include "rtl/define.v"

module mem_wb_reg(
    input wire clk,
    input wire rst_n,

    input wire [4:0] rd_in,
    input wire reg_write_in,
    input wire [1:0] wb_sel_in,

    input wire [31:0] alu_result_in,
    input wire [31:0] mem_data_in,
    input wire [31:0] pc_plus4_in,

    output wire [4:0] rd_out,
    output wire reg_write_out,
    output wire [1:0] wb_sel_out,

    output wire [31:0] alu_result_out,
    output wire [31:0] mem_data_out,
    output wire [31:0] pc_plus4_out
);

    localparam ZERO_WORD = 32'h0;
    localparam ZERO_REG = 5'h0;

    reg [4:0] mem_wb_rd;
    reg mem_wb_reg_write;
    reg [1:0] mem_wb_wb_sel;

    reg [31:0] mem_wb_alu_result;
    reg [31:0] mem_wb_mem_data;
    reg [31:0] mem_wb_pc_plus4;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mem_wb_rd         <= ZERO_REG;
            mem_wb_reg_write  <= 1'b0;
            mem_wb_wb_sel     <= `WB_ALU;
            mem_wb_alu_result <= ZERO_WORD;
            mem_wb_mem_data   <= ZERO_WORD;
            mem_wb_pc_plus4   <= ZERO_WORD;
        end else begin
            mem_wb_rd         <= rd_in;
            mem_wb_reg_write  <= reg_write_in;
            mem_wb_wb_sel     <= wb_sel_in;
            mem_wb_alu_result <= alu_result_in;
            mem_wb_mem_data   <= mem_data_in;
            mem_wb_pc_plus4   <= pc_plus4_in;
        end
    end

    assign rd_out         = mem_wb_rd;
    assign reg_write_out  = mem_wb_reg_write;
    assign wb_sel_out     = mem_wb_wb_sel;
    assign alu_result_out = mem_wb_alu_result;
    assign mem_data_out   = mem_wb_mem_data;
    assign pc_plus4_out   = mem_wb_pc_plus4;

endmodule
