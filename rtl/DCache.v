
module DCache(
    input wire clk,

    input wire is_mem_read,
    input wire is_mem_write,

    input wire [31:0] addr,
    input wire [31:0] wdata,

    output wire [31:0] rdata
);

    parameter DCACHE_DEPTH = 256;

    reg [31:0] cache_mem [0:DCACHE_DEPTH-1];

    integer i;

    wire [29:0] word_addr;

    assign word_addr = addr[31:2]; // 地址右移2位作为索引

    // 当前先用简单存储体代替DCache，后续可在这里加入tag/valid/miss处理
    initial begin
        for(i = 0; i < DCACHE_DEPTH; i = i + 1) begin
            cache_mem[i] = 32'h0;
        end
    end

    always @(posedge clk) begin
        if(is_mem_write) begin
            cache_mem[word_addr] <= wdata;
        end
    end

    assign rdata = is_mem_read ? cache_mem[word_addr] : 32'h0;

endmodule
