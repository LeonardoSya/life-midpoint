# SwiftUI 响应式布局指南

> 解决 ZStack + VStack + padding + maxWidth.infinity 子元素导致的内容溢出问题。

## 一、问题现象

页面在 iPhone 上出现以下症状之一：
- 输入框、按钮等元素**右边超出屏幕**被裁剪
- VStack 整体偏左，左 padding 正常但右边溢出
- 同一 VStack 中部分元素正常、部分溢出（典型差异：底部按钮正常，中间输入框溢出）

## 二、根本原因（重要）

SwiftUI 中 `.frame(maxWidth: .infinity)` 的语义是**"我可以最大撑到 infinity"**，
它**不会反向约束 children**。当某个深层 child（比如按钮内的 Text 用了 `.frame(maxWidth: .infinity)`）
让父 VStack 的 ideal size 变成 infinity 时，再在外层加一层 `.frame(maxWidth: .infinity)`
也**无法把已经 infinity 的子树压回到屏幕宽度**。

```swift
// ❌ 错误写法 (内容会溢出)
ZStack {
    background
    VStack {
        Button("登入") {}
            .frame(maxWidth: .infinity)   // ← 让 VStack 变 infinity
    }
    .padding(.horizontal, 40)
    .frame(maxWidth: .infinity, maxHeight: .infinity)   // ← 没用
}
```

外层 `.frame(maxWidth: .infinity)` 只是声明"能撑大"，不强制压回屏幕宽。

## 三、正确解决方案

### 方案 A: 用 `.responsiveFill()` 修饰符（推荐）

`Shared/Components/ResponsiveScreen.swift` 中已实现，内部基于 iOS 17+ 的
`containerRelativeFrame([.horizontal, .vertical])`，会强制锁定到 nearest container 的实际尺寸。

```swift
// ✅ 正确写法
ZStack {
    background
    VStack {
        Button("登入") {}
            .frame(maxWidth: .infinity)
    }
    .padding(.horizontal, 40)
    .responsiveFill()                    // ← 真正解决问题
}
.ignoresSafeArea()
```

### 方案 B: 用 `ResponsiveScreen` 容器（新页面推荐）

```swift
ResponsiveScreen {
    LinearGradient(...)                   // background
} content: {
    VStack { ... }
        .padding(.horizontal, 40)
}
```

容器内部用 `GeometryReader` 显式锁定子视图宽高 = 父容器实际尺寸。

## 四、Modifier 顺序

`.responsiveFill()` 必须放在 `.padding()` **之后**：

```swift
VStack { ... }
    .padding(.horizontal, 40)     // ① 内边距
    .padding(.bottom, 24)
    .responsiveFill()              // ② 锁定外层尺寸
```

如果反过来（先 `.responsiveFill()` 再 `.padding()`），padding 会加在已经撑满的 view 外面，
让总宽 = 屏幕宽 + 80，反而溢出。

## 五、为什么 `.frame(maxWidth: .infinity)` 不够

| 方案 | 行为 | 能否压回子树 |
|---|---|---|
| `.frame(maxWidth: .infinity)` | "我能最大撑到 infinity" | ❌ |
| `.frame(width: 393)` | 显式宽度 | ✅ 但写死不好 |
| `GeometryReader { .frame(width: geo.size.width) }` | 动态读父容器宽度 | ✅ |
| `.containerRelativeFrame(.horizontal)` (iOS 17+) | 锁到 nearest container | ✅ Apple 官方推荐 |

## 六、常见页面模板

### 全屏 ZStack 页面

```swift
struct MyPage: View {
    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 16) {
                // 任意 child 用 maxWidth.infinity 都安全
                contentSection
                actionButton
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
            .responsiveFill()                    // ← 关键
        }
        .ignoresSafeArea()
    }
}
```

### ScrollView 页面

```swift
ScrollView {
    VStack {
        ...
    }
    .padding(.horizontal, 24)
    .frame(maxWidth: .infinity)                  // ScrollView 内只需限宽
}
```

### 弹窗 / 对话框

```swift
VStack { ... }
    .frame(width: 320)                            // 锁死宽度
    .padding(24)
    .background(...)
```

## 七、Code Review Checklist

- [ ] 全屏 ZStack 内的 VStack 是否调用了 `.responsiveFill()` 或包在 `ResponsiveScreen` 中？
- [ ] `.responsiveFill()` 是否在 `.padding()` 之后？
- [ ] ScrollView 内的容器是否有 `.frame(maxWidth: .infinity)` 限宽？
- [ ] 弹窗类视图是否用 `.frame(width:)` 锁定宽度？

## 八、自动化检查

```bash
python3 scripts/check_responsive.py
```

脚本会扫描 Swift 文件，找出 ZStack + VStack + padding 但缺少响应式约束的页面。
