

module if_id_reg(
    input wire clk,
    input wire rst_n,

    input wire write_enable,       // IF/ID级间寄存器写使能
    input wire flush,              // 清空IF/ID级间寄存器
    input wire [31:0] pc_in,
    input wire [31:0] instr_in,

    output wire [31:0] pc_out,
    output wire [31:0] instr_out
);

    localparam ZERO_PC = 32'h0;
    localparam NOP = 32'h00000013;

    reg [31:0] if_id_pc;
    reg [31:0] if_id_instr;

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            if_id_pc <= ZERO_PC;
            if_id_instr <= NOP;
        end else if (flush) begin
            if_id_pc <= ZERO_PC;
            if_id_instr <= NOP;
        end else if (write_enable) begin
            if_id_pc <= pc_in;
            if_id_instr <= instr_in;
        end
    end

    assign pc_out = if_id_pc;
    assign instr_out = if_id_instr;

endmodule



