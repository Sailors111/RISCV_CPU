
// rtl/instr_rom.v

module instr_rom(
    input wire [31:0] addr,         // 指令地址
    output wire [31:0] instr         // 指令内容
);
    parameter instr_count = 256;
    reg [31:0] mem [0:instr_count-1];
    
    // 从hex文件加载指令（文件不存在时，默认全0）
    initial begin
        for(integer i = 0; i < instr_count; i = i + 1) begin
            mem[i] = 32'h00000013;  // NOP
        end
        $readmemh("hex/test.hex", mem);
    end
    
    assign instr = mem[addr[31:2]]; // 地址右移2位作为索引
endmodule

