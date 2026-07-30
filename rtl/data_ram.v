


module data_ram(
    input wire clk,

    input wire is_mem_read,
    input wire is_mem_write,

    input wire [31:0] addr,
    input wire [31:0] wdata,

    output wire [31:0] rdata
);

    parameter data_depth = 256;
    reg [31:0] mem [0:data_depth-1];

    integer i;
    initial begin
        for(i = 0; i < data_depth; i = i + 1) begin
            mem[i] = 32'h0;
        end
    end

    always @(posedge clk) begin
        if(is_mem_write) begin
            mem[addr[31:2]] <= wdata;
        end
    end

    assign rdata = is_mem_read ? mem[addr[31:2]] : 32'h0;

endmodule


