
// rtl/pc.v

module pc(
    input wire clk,             // 时钟信号
    input wire rst_n,           // 复位
    input wire [31:0] pc_next,       // 下一个PC值
    output wire [31:0] pc        // 输出新的PC值
);
    reg [31:0] pc_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pc_reg <= 32'h0;
    end else begin
        pc_reg <= pc_next;
    end
end

    assign pc = pc_reg;

endmodule



