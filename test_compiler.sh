#!/bin/bash
# filepath: test_compiler.sh

echo "=== 编译器测试 ==="

# 测试用例和预期结果
declare -A tests
tests["17.tc"]="159"
tests["19.tc"]="124"
tests["20.tc"]="104"
tests["check.tc"]="1"

for test_file in "${!tests[@]}"; do
    expected="${tests[$test_file]}"
    echo "测试: $test_file (预期返回: $expected)"
    
    # 编译
    dune exec bin/main.exe -- "test/$test_file"
    if [ $? -ne 0 ]; then
        echo "编译失败: $test_file"
        continue
    fi
    
        # 汇编和运行
    output_s="test/${test_file%.tc}.s"
    output_bin="test/${test_file%.tc}"

    # 使用静态链接避免动态链接器问题
    riscv64-linux-gnu-gcc -march=rv32im -mabi=ilp32 -static -nostartfiles -o "$output_bin" "$output_s"
    if [ $? -ne 0 ]; then
        echo "汇编失败: $test_file，尝试其他选项..."
        # 备选方案：生成目标文件然后链接
        riscv64-linux-gnu-as -march=rv32im -mabi=ilp32 -o "${output_bin}.o" "$output_s"
        riscv64-linux-gnu-ld -m elf32lriscv -static -o "$output_bin" "${output_bin}.o"
    fi
    
    if [ ! -f "$output_bin" ]; then
        echo "生成可执行文件失败: $test_file"
        continue
    fi
    
    # 运行并检查结果
    qemu-riscv32-static "./$output_bin"
    actual=$?
    
    if [ "$actual" -eq "$expected" ]; then
        echo "通过: $test_file"
    else
        echo "失败: $test_file (期望:$expected, 实际:$actual)"
    fi
    
    echo ""
done