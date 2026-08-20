
`include "define.v"


module alu(
    input  wire [4:0]  alu_op,
    input  wire [31:0] op1,
    input  wire [31:0] op2,
    output reg  [31:0] result
);

    always @(*) begin
        case (alu_op)
            `ALU_ADD: 
                result = op1 + op2;
            `ALU_SUB: 
                result = op1 - op2;
            `ALU_AND: 
                result = op1 & op2;
            `ALU_OR: 
                result = op1 | op2;
            `ALU_XOR: 
                result = op1 ^ op2;
            `ALU_SLL: 
                result = op1 << op2[4:0];
            `ALU_SRL: 
                result = op1 >> op2[4:0];
            `ALU_SRA: 
                result = $signed(op1) >>> op2[4:0];
            `ALU_SLT: 
                result = ($signed(op1) < $signed(op2)) ? 32'd1 : 32'd0;
            `ALU_SLTU: 
                result = (op1 < op2) ? 32'd1 : 32'd0;
            `ALU_PASS: 
                result = op2;
            default: 
                result = 32'h0;
        endcase
    end

endmodule
