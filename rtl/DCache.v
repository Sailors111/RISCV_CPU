
`include "rtl/define.v"

module DCache(
    input wire clk,

    input wire is_mem_read,
    input wire is_mem_write,
    input wire [2:0] mem_funct3,

    input wire [31:0] addr,
    input wire [31:0] wdata,

    output reg [31:0] rdata
);

    parameter DCACHE_DEPTH = 256;

    reg [31:0] cache_mem [0:DCACHE_DEPTH-1];

    wire [29:0] word_addr;
    wire [31:0] read_word;
    wire [31:0] write_word;
    reg [7:0] load_byte;
    reg [15:0] load_half;

    assign word_addr = addr[31:2]; // 地址右移2位作为索引
    assign read_word = cache_mem[word_addr];
    assign write_word = cache_mem[word_addr];

    // 当前先用简单存储体代替DCache，后续可在这里加入tag/valid/miss处理
    integer i;
    initial begin
        for(i = 0; i < DCACHE_DEPTH; i = i + 1) begin
            cache_mem[i] = 32'h0;
        end
    end

    always @(posedge clk) begin
        if(is_mem_write) begin
            // 当前暂不处理非对齐访存异常，lh/sh默认使用addr[1]选择半字
            case(mem_funct3)
                `F3_SB: begin
                    case(addr[1:0])
                        2'b00: cache_mem[word_addr] <= {write_word[31:8], wdata[7:0]};
                        2'b01: cache_mem[word_addr] <= {write_word[31:16], wdata[7:0], write_word[7:0]};
                        2'b10: cache_mem[word_addr] <= {write_word[31:24], wdata[7:0], write_word[15:0]};
                        2'b11: cache_mem[word_addr] <= {wdata[7:0], write_word[23:0]};
                    endcase
                end
                `F3_SH: begin
                    if(addr[1]) begin
                        cache_mem[word_addr] <= {wdata[15:0], write_word[15:0]};
                    end else begin
                        cache_mem[word_addr] <= {write_word[31:16], wdata[15:0]};
                    end
                end
                `F3_SW: begin
                    cache_mem[word_addr] <= wdata;
                end
                default: begin
                    cache_mem[word_addr] <= write_word;
                end
            endcase
        end
    end

    always @(*) begin
        case(addr[1:0])
            2'b00: load_byte = read_word[7:0];
            2'b01: load_byte = read_word[15:8];
            2'b10: load_byte = read_word[23:16];
            2'b11: load_byte = read_word[31:24];
        endcase

        load_half = addr[1] ? read_word[31:16] : read_word[15:0];

        if(is_mem_read) begin
            case(mem_funct3)
                `F3_LB: begin
                    rdata = {{24{load_byte[7]}}, load_byte};
                end
                `F3_LH: begin
                    rdata = {{16{load_half[15]}}, load_half};
                end
                `F3_LW: begin
                    rdata = read_word;
                end
                `F3_LBU: begin
                    rdata = {24'h0, load_byte};
                end
                `F3_LHU: begin
                    rdata = {16'h0, load_half};
                end
                default: begin
                    rdata = 32'h0;
                end
            endcase
        end else begin
            rdata = 32'h0;
        end
    end

endmodule
