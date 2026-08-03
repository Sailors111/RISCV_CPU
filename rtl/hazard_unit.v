

module hazard_unit(
    input wire id_ex_is_mem_read,
    input wire [4:0] id_ex_rd,

    input wire [4:0] id_rs1,
    input wire [4:0] id_rs2,
    input wire id_use_rs1,
    input wire id_use_rs2,

    output wire pc_write,
    output wire if_id_write,
    output wire id_ex_flush
);

    wire load_use_hazard;

    assign load_use_hazard = id_ex_is_mem_read && (id_ex_rd != 5'd0) && 
        ((id_use_rs1 && (id_ex_rd == id_rs1)) || (id_use_rs2 && (id_ex_rd == id_rs2)));

    assign pc_write = !load_use_hazard;         // 出现load-use时不写PC
    assign if_id_write = !load_use_hazard;      // 出现load-use时不写IF/ID级间寄存器
    assign id_ex_flush = load_use_hazard;       // 出现load-use时，往EX阶段插入一个bubble

endmodule
