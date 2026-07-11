# iOS 键盘输入适配实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让 App 内全部 SwiftUI 输入控件在键盘出现后保持可见，并统一支持滚动、空白点击或“完成”按钮收起键盘。

**Architecture:** 保留 SwiftUI 原生键盘安全区避让，不监听或计算固定键盘高度。背景继续全屏，前景输入容器只忽略 `.container` 安全区；各页面通过局部 `@FocusState`、滚动容器和键盘工具栏管理焦点。

**Tech Stack:** Swift 6、SwiftUI、iOS 17、Python 3 `unittest` 静态源码回归检查、XcodeGen、`xcodebuild`

**工作区约束:** 当前工作区已有用户对 `.gitignore`、`README.md`、`run.sh`、`scripts/start_agent_server.sh` 的未提交修改。实施时不得覆盖或提交这些修改；除非用户另行明确要求，本计划不创建 Git commit。

---

## 文件结构

- Create: `tests/test_keyboard_adaptation.py` — 对全部键盘输入点做静态回归检查。
- Modify: `LifeMidpoint/Features/Diary/DiarySummaryView.swift` — 恢复前景键盘安全区。
- Modify: `LifeMidpoint/Features/Onboarding/OnboardingStepView.swift` — 恢复引导输入区键盘避让。
- Modify: `LifeMidpoint/Features/Auth/LoginView.swift` — 增加滚动布局、字段焦点和数字键盘完成按钮。
- Modify: `LifeMidpoint/Features/Diary/EmotionPickerSheet.swift` — 自定义情绪提交及操作时清除焦点。
- Modify: `LifeMidpoint/Features/Mind/EmotionRecognitionGate.swift` — 情绪弹层支持交互式收起。
- Modify: `LifeMidpoint/Features/PostOffice/WriteLetterView.swift` — 化名输入焦点与滚动收起。
- Modify: `LifeMidpoint/Features/PostOffice/WriteLetterDefaultView.swift` — 正文编辑交互式收起与键盘完成按钮。
- Verify only: `LifeMidpoint/Features/Diary/DiaryView.swift` — 保留现有正确实现并纳入回归检查。

### Task 1: 高风险安全区回归

**Files:**
- Create: `tests/test_keyboard_adaptation.py`
- Modify: `LifeMidpoint/Features/Diary/DiarySummaryView.swift:18-49`
- Modify: `LifeMidpoint/Features/Onboarding/OnboardingStepView.swift:43-116`

- [ ] **Step 1: 写入会失败的安全区测试**

创建 `tests/test_keyboard_adaptation.py`：

```python
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def source(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


class KeyboardSafeAreaTests(unittest.TestCase):
    def test_diary_summary_preserves_keyboard_safe_area(self) -> None:
        content = source("LifeMidpoint/Features/Diary/DiarySummaryView.swift")
        self.assertIn(".ignoresSafeArea(.container)", content)
        self.assertNotIn(
            "\n        .ignoresSafeArea()\n        .overlay(alignment: .topLeading)",
            content,
        )

    def test_onboarding_preserves_keyboard_safe_area(self) -> None:
        content = source("LifeMidpoint/Features/Onboarding/OnboardingStepView.swift")
        self.assertIn(".ignoresSafeArea(.container)", content)
        self.assertNotIn(".ignoresSafeArea(.keyboard)", content)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: 运行测试并确认按预期失败**

Run:

```bash
python3 -m unittest tests.test_keyboard_adaptation.KeyboardSafeAreaTests -v
```

Expected: 2 个测试均为 `FAIL`；失败原因分别是缺少 `.ignoresSafeArea(.container)`，以及引导页仍包含 `.ignoresSafeArea(.keyboard)`。

- [ ] **Step 3: 修复日记总结页前景安全区**

将 `DiarySummaryView.body` 末尾的无参数忽略改为只忽略容器安全区：

```swift
        }
        .ignoresSafeArea(.container)
        .overlay(alignment: .topLeading) { backButton }
```

背景自身的 `background.ignoresSafeArea()` 保持不变。

- [ ] **Step 4: 修复引导页前景安全区**

将 `OnboardingStepView.body` 末尾：

```swift
        .ignoresSafeArea()
        .ignoresSafeArea(.keyboard)
```

替换为：

```swift
        .ignoresSafeArea(.container)
```

`backgroundImage` 和分屏遮罩自己的 `.ignoresSafeArea()` 保持不变。

- [ ] **Step 5: 运行安全区测试并确认通过**

Run:

```bash
python3 -m unittest tests.test_keyboard_adaptation.KeyboardSafeAreaTests -v
```

Expected: `Ran 2 tests`，结果 `OK`。

### Task 2: 登录页数字键盘与小屏布局

**Files:**
- Modify: `tests/test_keyboard_adaptation.py`
- Modify: `LifeMidpoint/Features/Auth/LoginView.swift:3-42`
- Modify: `LifeMidpoint/Features/Auth/LoginView.swift:65-96`
- Modify: `LifeMidpoint/Features/Auth/LoginView.swift:100-111`

- [ ] **Step 1: 写入会失败的登录页测试**

在测试文件中加入：

```python
class LoginKeyboardTests(unittest.TestCase):
    def test_login_has_scroll_focus_and_keyboard_done_action(self) -> None:
        content = source("LifeMidpoint/Features/Auth/LoginView.swift")
        self.assertIn("@FocusState private var focusedField: Field?", content)
        self.assertIn("ScrollView(showsIndicators: false)", content)
        self.assertIn(".scrollDismissesKeyboard(.interactively)", content)
        self.assertIn("ToolbarItemGroup(placement: .keyboard)", content)
        self.assertIn(".focused($focusedField, equals: .phone)", content)
        self.assertIn(".focused($focusedField, equals: .code)", content)
```

- [ ] **Step 2: 运行登录页测试并确认失败**

Run:

```bash
python3 -m unittest tests.test_keyboard_adaptation.LoginKeyboardTests -v
```

Expected: `FAIL`，首个缺失项为 `@FocusState private var focusedField: Field?`。

- [ ] **Step 3: 增加登录字段焦点类型**

在状态属性后加入：

```swift
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case phone
        case code
    }
```

- [ ] **Step 4: 将登录内容改为可滚动键盘安全布局**

用以下结构替换前景 `VStack`，内部原有 section 顺序不变：

```swift
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 32)
                    titleSection
                    Spacer().frame(height: 64)
                    inputSection
                    Spacer().frame(height: 32)
                    loginButton
                    termsSection.padding(.top, AppSpacing.lg)
                    Spacer().frame(height: 56)
                    alternativeLoginSection
                    Spacer(minLength: 32)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 40)
                .padding(.vertical, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .responsiveFill()
```

- [ ] **Step 5: 绑定焦点并增加数字键盘完成按钮**

手机号字段加入：

```swift
                .focused($focusedField, equals: .phone)
```

验证码字段加入：

```swift
                    .focused($focusedField, equals: .code)
```

在根 `ZStack` 后加入：

```swift
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") { focusedField = nil }
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.textPrimary)
            }
        }
```

登录按钮 action 第一行加入 `focusedField = nil`。

- [ ] **Step 6: 运行登录页测试并确认通过**

Run:

```bash
python3 -m unittest tests.test_keyboard_adaptation.LoginKeyboardTests -v
```

Expected: `Ran 1 test`，结果 `OK`。

### Task 3: 情绪自定义输入

**Files:**
- Modify: `tests/test_keyboard_adaptation.py`
- Modify: `LifeMidpoint/Features/Diary/EmotionPickerSheet.swift:94-119`
- Modify: `LifeMidpoint/Features/Diary/EmotionPickerSheet.swift:156-184`
- Modify: `LifeMidpoint/Features/Mind/EmotionRecognitionGate.swift:39-53`

- [ ] **Step 1: 写入会失败的情绪输入测试**

```python
class EmotionKeyboardTests(unittest.TestCase):
    def test_emotion_picker_dismisses_keyboard_from_all_exit_paths(self) -> None:
        picker = source("LifeMidpoint/Features/Diary/EmotionPickerSheet.swift")
        gate = source("LifeMidpoint/Features/Mind/EmotionRecognitionGate.swift")
        self.assertIn(".onSubmit { customFieldFocused = false }", picker)
        self.assertIn("customFieldFocused = false\n            let content =", picker)
        self.assertIn("customFieldFocused = false\n            if let onSkip", picker)
        self.assertIn(".scrollDismissesKeyboard(.interactively)", gate)
```

- [ ] **Step 2: 运行情绪输入测试并确认失败**

Run:

```bash
python3 -m unittest tests.test_keyboard_adaptation.EmotionKeyboardTests -v
```

Expected: `FAIL`，因为自定义字段没有 `onSubmit`。

- [ ] **Step 3: 补齐自定义输入的焦点清理**

在自定义 `TextField` 上加入：

```swift
                .onSubmit { customFieldFocused = false }
```

确认按钮 action 开头加入：

```swift
            customFieldFocused = false
            let content = EmotionLibrary.content(for: effectiveEmotionName)
```

跳过按钮 action 改为：

```swift
        Button {
            customFieldFocused = false
            if let onSkip { onSkip() } else { dismiss() }
        } label: {
```

- [ ] **Step 4: 让情绪弹层支持下拉收起**

在 `EmotionRecognitionGate.picker` 的外层 `ScrollView` 后加入：

```swift
        .scrollDismissesKeyboard(.interactively)
```

- [ ] **Step 5: 运行情绪输入测试并确认通过**

Run:

```bash
python3 -m unittest tests.test_keyboard_adaptation.EmotionKeyboardTests -v
```

Expected: `Ran 1 test`，结果 `OK`。

### Task 4: 写信化名与正文编辑

**Files:**
- Modify: `tests/test_keyboard_adaptation.py`
- Modify: `LifeMidpoint/Features/PostOffice/WriteLetterView.swift:4-20`
- Modify: `LifeMidpoint/Features/PostOffice/WriteLetterView.swift:33-103`
- Modify: `LifeMidpoint/Features/PostOffice/WriteLetterView.swift:209-289`
- Modify: `LifeMidpoint/Features/PostOffice/WriteLetterDefaultView.swift:45-121`

- [ ] **Step 1: 写入会失败的写信输入测试**

```python
class LetterKeyboardTests(unittest.TestCase):
    def test_alias_field_has_focus_and_interactive_dismissal(self) -> None:
        content = source("LifeMidpoint/Features/PostOffice/WriteLetterView.swift")
        self.assertIn("@FocusState private var isAliasFocused: Bool", content)
        self.assertIn(".focused($isAliasFocused)", content)
        self.assertIn(".scrollDismissesKeyboard(.interactively)", content)
        self.assertIn(".onSubmit { isAliasFocused = false }", content)

    def test_full_writer_has_interactive_and_explicit_dismissal(self) -> None:
        content = source("LifeMidpoint/Features/PostOffice/WriteLetterDefaultView.swift")
        self.assertIn(".scrollDismissesKeyboard(.interactively)", content)
        self.assertIn("ToolbarItemGroup(placement: .keyboard)", content)
        self.assertIn('Button("完成") { isFocused = false }', content)
```

- [ ] **Step 2: 运行写信输入测试并确认失败**

Run:

```bash
python3 -m unittest tests.test_keyboard_adaptation.LetterKeyboardTests -v
```

Expected: 2 个测试均为 `FAIL`。

- [ ] **Step 3: 增加化名焦点和滚动收起**

在 `WriteLetterView` 状态属性后加入：

```swift
    @FocusState private var isAliasFocused: Bool
```

外层纵向 `ScrollView` 后加入：

```swift
            .scrollDismissesKeyboard(.interactively)
```

化名 `TextField` 加入：

```swift
                .focused($isAliasFocused)
                .submitLabel(.done)
                .onSubmit { isAliasFocused = false }
```

打开全屏正文和完成撰写前分别执行 `isAliasFocused = false`。`chipButton` 的 action 开头也执行 `isAliasFocused = false`，确保选择下方标签时键盘退场。

- [ ] **Step 4: 增加正文编辑的收起入口**

在 `TextEditor` 修饰符链加入：

```swift
                        .scrollDismissesKeyboard(.interactively)
```

在根视图末尾加入：

```swift
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") { isFocused = false }
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.inkBrownDark)
            }
        }
```

- [ ] **Step 5: 运行写信输入测试并确认通过**

Run:

```bash
python3 -m unittest tests.test_keyboard_adaptation.LetterKeyboardTests -v
```

Expected: `Ran 2 tests`，结果 `OK`。

### Task 5: 日记页与全量输入点回归

**Files:**
- Modify: `tests/test_keyboard_adaptation.py`
- Verify only: `LifeMidpoint/Features/Diary/DiaryView.swift`

- [ ] **Step 1: 增加日记现有正确行为和输入清单测试**

```python
class InputInventoryTests(unittest.TestCase):
    EXPECTED_INPUT_COUNTS = {
        "LifeMidpoint/Features/Diary/DiaryView.swift": 1,
        "LifeMidpoint/Features/Diary/DiarySummaryView.swift": 1,
        "LifeMidpoint/Features/Auth/LoginView.swift": 2,
        "LifeMidpoint/Features/Diary/EmotionPickerSheet.swift": 1,
        "LifeMidpoint/Features/PostOffice/WriteLetterView.swift": 1,
        "LifeMidpoint/Features/PostOffice/WriteLetterDefaultView.swift": 1,
        "LifeMidpoint/Features/Onboarding/OnboardingStepView.swift": 2,
    }

    def test_all_keyboard_inputs_are_registered(self) -> None:
        discovered: dict[str, int] = {}
        features = ROOT / "LifeMidpoint" / "Features"
        for path in features.rglob("*.swift"):
            content = path.read_text(encoding="utf-8")
            count = len(re.findall(r"\b(?:TextField|SecureField|TextEditor)\s*\(", content))
            if count:
                discovered[str(path.relative_to(ROOT))] = count
        self.assertEqual(discovered, self.EXPECTED_INPUT_COUNTS)

    def test_diary_keeps_input_above_keyboard_and_latest_message_visible(self) -> None:
        content = source("LifeMidpoint/Features/Diary/DiaryView.swift")
        self.assertIn(".ignoresSafeArea(.container)", content)
        self.assertIn(".scrollDismissesKeyboard(.interactively)", content)
        self.assertIn(".onChange(of: isInputFocused)", content)
        self.assertIn("proxy.scrollTo(last, anchor: .bottom)", content)
```

- [ ] **Step 2: 运行全量静态回归**

Run:

```bash
python3 -m unittest discover -s tests -p "test_keyboard_adaptation.py" -v
```

Expected: `Ran 8 tests`，结果 `OK`。如果输入清单失败，先核对是否有未盘点的输入控件，不得直接修改预期数量掩盖遗漏。

### Task 6: 构建与交互验证

**Files:**
- Verify: `project.yml`
- Verify: 所有本计划涉及的 Swift 文件

- [ ] **Step 1: 生成 Xcode 工程**

Run:

```bash
xcodegen generate
```

Expected: 输出 `Generated project at .../LifeMidpoint.xcodeproj`，退出码 0。

- [ ] **Step 2: 构建 iOS 模拟器版本**

Run:

```bash
xcodebuild -project LifeMidpoint.xcodeproj -scheme LifeMidpoint -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
```

Expected: 退出码 0，末尾为 `** BUILD SUCCEEDED **`，没有 Swift 编译错误。

- [ ] **Step 3: 逐页模拟器验证**

按以下顺序人工验证：

1. 日记：点击底部输入条，输入条位于键盘上方，最新消息自动滚到可见区域；下拉消息区收起键盘。
2. 日记总结：编辑长文本，输入卡片和“完成记录”可滚动到达；键盘工具栏“完成”可收起键盘。
3. 写信正文：自动聚焦后正文与底部工具条均可见；下拉或键盘“完成”可收起。
4. 登录：分别点击手机号和验证码；内容可滚动；数字键盘“完成”可收起；登录动作清除焦点。
5. 情绪：点击“自定义”，输入框保持可见；下拉、回车、确认和跳过均可收起。
6. 写信化名：输入框保持可见；下拉、回车、点击标签、打开正文和完成撰写均清除焦点。
7. 引导文字与档案：自动聚焦后输入框和确认按钮位于键盘上方或可滚动到达；打开生日选择时姓名键盘消失。

- [ ] **Step 4: 检查最终差异**

Run:

```bash
git diff --check
git status --short
```

Expected: `git diff --check` 无输出且退出码 0；状态只包含用户原有修改、本计划涉及的 Swift 文件、测试文件和两份设计/计划文档。
