

`include "define.v"


module forwarding_unit(
    input wire [4:0] id_ex_rs1,
    input wire [4:0] id_ex_rs2,

    input wire [4:0] ex_mem_rd,
    input wire ex_mem_reg_write,
    input wire ex_mem_is_mem_read,

    input wire [4:0] mem_wb_rd,
    input wire mem_wb_reg_write,

    output reg [1:0] forward_rs1,
    output reg [1:0] forward_rs2
);

    always @(*)begin
        forward_rs1 = 2'b00;
        forward_rs2 = 2'b00;

        if(
            ex_mem_reg_write &&        // EX/MEM 段需要写寄存器
            ex_mem_rd == id_ex_rs1 &&   // EX/MEM 段目的寄存器与 ID/EX 段源寄存器相同
            ex_mem_rd != 5'd0 &&    // 目的寄存器不是x0
            !ex_mem_is_mem_read) begin // 不是读内存指令
            
            forward_rs1 = `FORWARD_EX;
        end else if(
            mem_wb_reg_write &&     // MEM/WB 段需要写寄存器
            mem_wb_rd == id_ex_rs1 &&    // MEM/WB 段目的寄存器与 ID/EX 段源寄存器相同
            mem_wb_rd != 5'd0       // 目的寄存器不是x0
        ) begin

            forward_rs1 = `FORWARD_MEM;
        end

        if(
            ex_mem_reg_write &&        // EX/MEM 段需要写寄存器
            ex_mem_rd == id_ex_rs2 &&   // EX/MEM 段目的寄存器与 ID/EX 段源寄存器相同
            ex_mem_rd != 5'd0 &&    // 目的寄存器不是x0
            !ex_mem_is_mem_read) begin // 不是读内存指令
            
            forward_rs2 = `FORWARD_EX;
        end else if(
            mem_wb_reg_write &&     // MEM/WB 段需要写寄存器
            mem_wb_rd == id_ex_rs2 &&    // MEM/WB 段目的寄存器与 ID/EX 段源寄存器相同
            mem_wb_rd != 5'd0       // 目的寄存器不是x0
        ) begin

            forward_rs2 = `FORWARD_MEM;
        end
    end

endmodule
