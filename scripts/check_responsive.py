#!/usr/bin/env python3
"""
扫描所有 Swift 文件, 找出潜在的响应式布局风险:
- ZStack { ... VStack { ... } } 全屏布局
- 内容容器有 .padding 但缺少响应式约束 (.responsiveFill / .frame(maxWidth: .infinity))
- 排除有 .frame(width:) 显式宽度的 (弹窗等)

用法: python3 scripts/check_responsive.py
退出码: 0 = OK, 1 = 有问题
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent / "LifeMidpoint" / "Features"

def has_responsive_constraint(content: str) -> bool:
    """检查是否有任意一种响应式宽度约束"""
    patterns = [
        r'\.responsiveFill\(\)',
        r'\.responsiveWidth\(\)',
        r'\.frame\(maxWidth:\s*\.infinity',
        r'\.frame\(width:\s*\d+',          # 锁定宽度的弹窗也算
        r'ResponsiveScreen',                 # 用了容器
    ]
    return any(re.search(p, content) for p in patterns)

def has_zstack_with_padding(content: str) -> bool:
    """检查是否有 ZStack 全屏 + padding 模式"""
    has_zstack = bool(re.search(r'ZStack\s*\{[^{]*\n[^}]*VStack', content, re.DOTALL))
    has_padding = '.padding(.horizontal' in content or '.padding(.vertical' in content
    return has_zstack and has_padding

def scan(file_path: Path) -> list[str]:
    content = file_path.read_text()
    if has_zstack_with_padding(content) and not has_responsive_constraint(content):
        return [str(file_path.relative_to(ROOT.parent.parent))]
    return []

def main() -> int:
    issues = []
    for swift_file in ROOT.rglob('*.swift'):
        issues.extend(scan(swift_file))

    if issues:
        print(f"⚠️  {len(issues)} files at risk:")
        for f in issues:
            print(f"  - {f}")
        print("\n→ See docs/RESPONSIVE_LAYOUT_GUIDE.md for fix patterns.")
        return 1

    print(f"✅ All Swift files use responsive layout patterns correctly.")
    return 0

if __name__ == '__main__':
    sys.exit(main())
