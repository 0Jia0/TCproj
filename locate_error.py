# 创建 locate_error.py
with open('test/check.tc', 'r') as f:
    content = f.read()

pos = 239
if pos < len(content):
    # 显示错误位置前后的内容
    start = max(0, pos - 30)
    end = min(len(content), pos + 30)
    context = content[start:end]
    error_char = content[pos] if pos < len(content) else 'EOF'
    
    print(f"错误位置: {pos}")
    print(f"错误字符: '{error_char}'")
    print(f"上下文: ...{context}...")
    print(f"指示器: {' ' * (pos - start)}^")