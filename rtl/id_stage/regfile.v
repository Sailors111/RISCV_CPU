

// rtl/regfile.v

module regfile (
    input wire clk,         // 时钟信号
    input wire we,          // 写使能信号（为1表示允许写）
    input wire [4:0] waddr,      // 写地址（目标寄存器编号，共32个寄存器，占5比特）
    input wire [31:0] wdata,     // 写数据
    input wire [4:0] raddr1,     // 读地址1（源寄存器1编号）
    input wire [4:0] raddr2,     // 读地址2（源寄存器2编号）
    output wire [31:0] rdata1,   // 读数据1
    output wire [31:0] rdata2    // 读数据2
);

    reg [31:0] regs [0:31]; // 32个通用寄存器

    // 寄存器初始化
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] = 32'h0;
        end
    end

    // 写操作（时序逻辑，只在时钟上升沿触发）
    always @ (posedge clk) begin
        if(we && (waddr != 5'd0)) begin
            regs[waddr] <= wdata;
        end
    end

    // 读操作（组合逻辑，立即输出）
    assign rdata1 = (raddr1 == 5'd0) ? 32'h0 : ((we && waddr == raddr1) ? wdata : regs[raddr1]);
    assign rdata2 = (raddr2 == 5'd0) ? 32'h0 : ((we && waddr == raddr2) ? wdata : regs[raddr2]);
endmodule

