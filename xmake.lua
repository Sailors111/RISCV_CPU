---@diagnostic disable: undefined-global, undefined-field

set_project("riscv_cpu")

local RTL_FILES = {
    "rtl/top.v",
    "rtl/if_stage/IF.v",
    "rtl/if_stage/ICache.v",
    "rtl/if_stage/pc.v",
    "rtl/id_stage/ID.v",
    "rtl/id_stage/decoder.v",
    "rtl/id_stage/regfile.v",
    "rtl/ex_stage/EX.v",
    "rtl/ex_stage/alu.v",
    "rtl/mem_stage/MEM.v",
    "rtl/mem_stage/DCache.v",
    "rtl/wb_stage/WB.v",
    "rtl/reg/if_id_reg.v",
    "rtl/reg/id_ex_reg.v",
    "rtl/reg/ex_mem_reg.v",
    "rtl/reg/mem_wb_reg.v",
    "rtl/pipeline_ctrl/hazard_unit.v",
    "rtl/pipeline_ctrl/forwarding_unit.v",
}

local RTL_INCLUDE_DIRS = {
    "rtl/include",
}

local TESTS = {
    { target = "test00", tb = "tb/tb_test00.sv" },
    { target = "test01", tb = "tb/tb_test01.sv" },
    { target = "test02", tb = "tb/tb_test02.sv" },
    { target = "test03", tb = "tb/tb_test03.sv" },
}

local function quote(value)
    return "\"" .. tostring(value) .. "\""
end

local function simv_path(target)
    return path.join(target:targetdir(), target:name() .. ".vvp")
end

local function add_test_target(test)
    target(test.target, function()
        set_kind("binary")
        set_default(true)
        set_group("riscv")

        on_build(function(target)
            os.mkdir(target:targetdir())

            local argv = {
                "iverilog",
                "-g2012",
                "-s",
                "tb_top",
                "-o",
                quote(simv_path(target)),
            }

            for _, dir in ipairs(RTL_INCLUDE_DIRS) do
                table.insert(argv, "-I")
                table.insert(argv, quote(path.absolute(dir, os.projectdir())))
            end

            for _, file in ipairs(RTL_FILES) do
                table.insert(argv, quote(path.absolute(file, os.projectdir())))
            end

            table.insert(argv, quote(path.absolute(test.tb, os.projectdir())))
            os.vrun(table.concat(argv, " "))
        end)

        on_run(function(target)
            os.exec("vvp " .. quote(simv_path(target)))
        end)
    end)
end

for _, test in ipairs(TESTS) do
    add_test_target(test)
end
