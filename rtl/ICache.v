
// rtl/instr_rom.v

module ICache(
    input wire [31:0] addr,         // 指令地址
    output wire [31:0] instr        // 指令内容
);

    parameter ICACHE_DEPTH = 256;
    parameter INIT_FILE = "hex/test.hex";

    localparam NOP = 32'h00000013;

    reg [31:0] cache_mem [0:ICACHE_DEPTH-1];

    integer i;

    // 当前先用简单存储体代替ICache，后续可在这里加入tag/valid/miss处理
    initial begin
        for(i = 0; i < ICACHE_DEPTH; i = i + 1) begin
            cache_mem[i] = NOP;
        end

        $readmemh(INIT_FILE, cache_mem);
    end

    assign instr = cache_mem[addr[31:2]]; // 地址右移2位作为索引

endmodule
