`timescale 1ns/1ps

module tb_top();
    reg clk, rst_n;
    wire [31:0] pc_out, instr_out;

    top u_top(
        .clk(clk),
        .rst_n(rst_n),
        .pc_out(pc_out),
        .instr_out(instr_out)
    );

    always #5 clk = ~clk;   // 时钟周期为10s

    initial begin
        clk = 0;
        rst_n = 0;
        #15;
        rst_n = 1;
        #200;
        $finish;
    end

    initial begin
        $monitor("time=%0t, pc=0x%h, instr=0x%h", $time, pc_out, instr_out);
    end

endmodule




