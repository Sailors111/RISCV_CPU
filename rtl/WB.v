
`include "rtl/define.v"

module WB(
    input wire clk,

    input wire [4:0] mem_rd,
    input wire mem_reg_write,
    input wire [1:0] mem_wb_sel,
    
    input wire [31:0] mem_alu_result,
    input wire [31:0] mem_data,
    input wire [31:0] mem_pc_plus4,

    output wire [4:0] wb_rd,
    output wire wb_reg_write,
    output reg [31:0] wb_wdata
);

    assign wb_rd = mem_rd;
    assign wb_reg_write = mem_reg_write;

    always @(*) begin
        case (mem_wb_sel)
            `WB_ALU: begin
                wb_wdata = mem_alu_result;
            end
            `WB_MEM: begin
                wb_wdata = mem_data;
            end
            `WB_PC4: begin
                wb_wdata = mem_pc_plus4;
            end
            default: begin
                wb_wdata = 32'h0;
            end
        endcase
    end

endmodule












