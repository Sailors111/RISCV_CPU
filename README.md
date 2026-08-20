# riscv_cpu

这是一个使用 Verilog 编写的教学型 RV32I 五级流水 CPU 项目。当前 RTL 重点实现了经典五级流水线的数据通路、指令译码、ALU 执行、访存、写回、级间寄存器、数据前递、load-use 暂停，以及分支/跳转后的流水线冲刷。

当前设计更适合学习 CPU 流水线基本结构和 RV32I 指令执行过程；它不是完整的工业级 RISC-V 处理器，也没有实现真正的 Cache、异常、中断、CSR 或外部总线协议。

## RTL 结构

顶层模块是 `rtl/top.v`，整体流水线结构如下：

```text
IF -> IF/ID -> ID -> ID/EX -> EX -> EX/MEM -> MEM -> MEM/WB -> WB
```

`rtl` 目录按流水线阶段和控制功能划分：

```text
rtl/
├── top.v
├── include/
│   └── define.v
├── if_stage/
│   ├── IF.v
│   ├── ICache.v
│   └── pc.v
├── id_stage/
│   ├── ID.v
│   ├── decoder.v
│   └── regfile.v
├── ex_stage/
│   ├── EX.v
│   └── alu.v
├── mem_stage/
│   ├── MEM.v
│   └── DCache.v
├── wb_stage/
│   └── WB.v
├── reg/
│   ├── if_id_reg.v
│   ├── id_ex_reg.v
│   ├── ex_mem_reg.v
│   └── mem_wb_reg.v
└── pipeline_ctrl/
    ├── hazard_unit.v
    └── forwarding_unit.v
```

## 模块说明

### 顶层

`rtl/top.v` 负责连接 IF、ID、EX、MEM、WB 五个阶段，实例化四组级间寄存器，并接入冒险检测和数据前递逻辑。它还提供了一些调试输出，例如 IF 阶段 PC/指令、流水线寄存器中的 ALU 结果、MEM/WB 数据、WB 写回寄存器号和写回数据。

`top` 带有 `PROGRAM_FILE` 和 `PROGRAM_WORDS` 参数。`PROGRAM_FILE` 默认值为 `hex/test00.txt`，用于选择指令存储器初始化文件；`PROGRAM_WORDS` 默认值为 `24`，表示 `$readmemh` 需要读取的有效指令条数。

### include

`rtl/include/define.v` 保存全局宏定义，包括：

- RV32I opcode
- funct3 / funct7
- ALU 操作码
- ALU 操作数选择
- WB 写回数据选择
- 分支/跳转类型
- 前递选择编码

### IF 取指阶段

`rtl/if_stage/pc.v` 是 PC 寄存器。复位后 PC 为 `0`，当 `pc_write` 为 1 时，在时钟上升沿更新为 `pc_next`。

`rtl/if_stage/ICache.v` 是指令存储模型。它内部使用 256 个 32 位 word 的数组，初始化时先填充 `addi x0, x0, 0` 形式的 NOP，再通过 `$readmemh` 读取 `INIT_FILE`。取指地址使用 `addr[31:2]` 作为 word 索引。

`rtl/if_stage/IF.v` 连接 PC 和 ICache，输出当前 PC 和当前指令。

注意：这里的 `ICache` 当前只是简单指令存储体，不包含 tag、valid、miss、替换策略或总线访问。

### ID 译码阶段

`rtl/id_stage/decoder.v` 解析指令字段，生成 `rd`、`rs1`、`rs2`、立即数、ALU 控制、访存控制、写回选择、分支类型，以及 `use_rs1/use_rs2` 冒险检测辅助信号。

`rtl/id_stage/regfile.v` 实现 32 个 32 位通用寄存器。`x0` 恒为 0，写回时禁止写 `x0`。读口是组合逻辑，并带有同周期写后读旁路：如果当前 WB 正在写同一个寄存器，读口直接返回写回数据。

`rtl/id_stage/ID.v` 封装 decoder 和 regfile，并把译码结果、寄存器读数据和 PC 送往下一级。

### EX 执行阶段

`rtl/ex_stage/alu.v` 实现加、减、与、或、异或、逻辑左移、逻辑右移、算术右移、有符号小于比较、无符号小于比较和直通操作。

`rtl/ex_stage/EX.v` 根据 `op1_sel/op2_sel` 选择 ALU 操作数，计算 ALU 结果、访存地址、store 数据、`PC + 4`、分支目标和 `jalr` 目标。分支条件也在 EX 阶段判断，`jal/jalr` 会直接认为跳转成立。

`jalr` 目标地址按 RISC-V 规则清除最低位：

```verilog
(rs1 + imm) & 32'hffff_fffe
```

### MEM 访存阶段

`rtl/mem_stage/MEM.v` 封装 DCache，并把 EX/MEM 传来的控制信号和数据继续送往 WB。

`rtl/mem_stage/DCache.v` 是数据存储模型，内部使用 256 个 32 位 word 的数组。写操作在时钟上升沿发生，读操作是组合逻辑。当前支持字节、半字、字访问：

- `lb/lbu` 通过 `addr[1:0]` 选择字节
- `lh/lhu` 通过 `addr[1]` 选择半字
- `lw` 读取整个 32 位 word
- `sb/sh/sw` 分别写字节、半字、整字

注意：这里的 `DCache` 当前只是简单数据存储体，不处理非对齐访存异常，也不包含真实 Cache 的 tag、valid、miss、替换策略或外部总线访问。

### WB 写回阶段

`rtl/wb_stage/WB.v` 根据 `wb_sel` 选择写回数据来源：

- `WB_ALU`：写回 ALU 结果
- `WB_MEM`：写回访存读数据
- `WB_PC4`：写回 `PC + 4`

同时，WB 阶段会屏蔽对 `x0` 的写回。

### 级间寄存器

`rtl/reg/if_id_reg.v` 保存 IF 到 ID 的 PC 和指令，支持 `write_enable` 暂停和 `flush` 冲刷。冲刷时写入 NOP。

`rtl/reg/id_ex_reg.v` 保存 ID 到 EX 的数据和控制信号，支持 `flush`。当需要插入 bubble 时，该模块把控制信号清成无副作用状态。

`rtl/reg/ex_mem_reg.v` 保存 EX 到 MEM 的 ALU 结果、store 数据、`PC + 4`、目的寄存器和访存/写回控制信号。

`rtl/reg/mem_wb_reg.v` 保存 MEM 到 WB 的目的寄存器、写回控制、ALU 结果、访存数据和 `PC + 4`。

### 流水线控制

`rtl/pipeline_ctrl/forwarding_unit.v` 实现 EX 阶段操作数前递。当前支持：

- 从 EX/MEM 阶段前递 ALU 或 `PC + 4` 结果
- 从 MEM/WB 阶段前递最终 WB 数据

为了避免错误前递 load 指令尚未返回的数据，EX/MEM 前递条件会排除 `ex_mem_is_mem_read`。

`rtl/pipeline_ctrl/hazard_unit.v` 检测 load-use 冒险。当 ID/EX 阶段是 load，并且其 `rd` 被当前 ID 阶段指令作为 `rs1` 或 `rs2` 使用时：

- 暂停 PC 更新
- 暂停 IF/ID 写入
- 冲刷 ID/EX，向 EX 阶段插入一个 bubble

分支和跳转在 EX 阶段给出 `branch_taken`。当跳转或分支成立时，`top.v` 会冲刷 IF/ID 和 ID/EX，避免错误路径指令继续执行。

## 已实现的指令

当前 RTL 按 `decoder.v`、`alu.v` 和 `DCache.v` 的实现，支持以下 RV32I 指令子集。

### R-type

```text
add  sub  and  or  xor
sll  srl  sra
slt  sltu
```

### I-type 算术/逻辑

```text
addi  andi  ori  xori
slli  srli  srai
slti  sltiu
```

### Load

```text
lb  lh  lw  lbu  lhu
```

### Store

```text
sb  sh  sw
```

### Branch

```text
beq  bne  blt  bge  bltu  bgeu
```

### Jump

```text
jal  jalr
```

### U-type

```text
lui  auipc
```

## 暂未实现或尚未完整验证的内容

- 真实 ICache/DCache 行为：tag、valid、dirty、miss、refill、替换策略等
- 外部内存总线协议
- 非对齐访存异常
- CSR、异常、中断、特权级
- `fence/fence.i/ecall/ebreak`
- RV32M 乘除法扩展
- 完整 RV32I ISA 合规测试

## 程序加载

指令镜像通过如下参数链路传入：

```text
top.PROGRAM_FILE -> IF.PROGRAM_FILE -> ICache.INIT_FILE
top.PROGRAM_WORDS -> IF.PROGRAM_WORDS -> ICache.INIT_WORDS
```

默认程序为：

```text
hex/test00.txt
```

`hex/` 目录下当前保留 4 个带注释的指令文本，每个文件开头说明测试目的，每条机器码后面都写有对应汇编指令：

```text
hex/test00.txt  ALU 运算指令测试
hex/test01.txt  load/store 访存指令测试
hex/test02.txt  branch 分支指令测试
hex/test03.txt  数据冒险与 load-use 测试
```

这些 `.txt` 文件供 `$readmemh` 读取。Icarus Verilog 支持文件中的 `//` 注释，因此机器码后面可以保留汇编说明。

## 构建和运行

当前项目提供 `xmake.lua`，测试平台是纯 SystemVerilog，不再依赖 Verilua。构建全部测试：

```bash
xmake build
```

也可以单独运行某个定向测试，例如：

```bash
xmake run test00
```

当前 `xmake.lua` 中列出的定向测试目标包括：

```text
test00
test01
test02
test03
```

`tb/` 目录下对应 4 个自检查 testbench：

```text
tb/tb_test00.sv
tb/tb_test01.sv
tb/tb_test02.sv
tb/tb_test03.sv
```

每个 testbench 都会在仿真结束时检查寄存器堆和必要的数据存储内容，并打印 `PASS` 或 `FAIL`。

如果直接使用 Icarus Verilog 做语法/展开检查，需要包含 `rtl/include`：

```bash
iverilog -g2012 -Irtl/include -tnull -o /tmp/riscv_cpu_rtl_check rtl/top.v rtl/if_stage/*.v rtl/id_stage/*.v rtl/ex_stage/*.v rtl/mem_stage/*.v rtl/wb_stage/*.v rtl/reg/*.v rtl/pipeline_ctrl/*.v
```

## GitHub 上传范围

为了保持仓库干净，除 `.gitignore` 本身外，准备上传到 GitHub 的项目内容只保留：

```text
docs/
hex/
rtl/
tb/
xmake.lua
README.md
.gitignore
```

本地仿真生成目录、波形文件、Verdi/Novas 日志、xmake 缓存等都不需要上传。`.gitignore` 已按这个目标配置。
