
// 取指IF

module IF #(
    parameter PROGRAM_FILE = "hex/test.hex"
)(
    input wire clk,
    input wire rst_n,

    input wire pc_write,
    input wire [31:0] pc_next,
    output wire [31:0] pc,
    output wire [31:0] instr
);

    wire [31:0] pc_wire;
    wire [31:0] icache_instr;

    pc u_pc(
        .clk    (clk),
        .rst_n  (rst_n),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc     (pc_wire)
    );

    ICache #(
        .INIT_FILE(PROGRAM_FILE)
    ) u_icache (
        .addr (pc_wire),
        .instr(icache_instr)
    );

    assign pc = pc_wire;
    assign instr = icache_instr;

endmodule
