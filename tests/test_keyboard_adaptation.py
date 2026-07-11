import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def source(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


class KeyboardSafeAreaTests(unittest.TestCase):
    """Task 1: 高风险前景容器不得吞掉键盘安全区。"""

    def test_diary_summary_preserves_keyboard_safe_area(self) -> None:
        content = source("LifeMidpoint/Features/Diary/DiarySummaryView.swift")
        # 根级 modifier 链: 紧邻 overlay 之前的 ignoresSafeArea 必须且仅为 .container
        match = re.search(
            r"\n        \.ignoresSafeArea\(([^)]*)\)\n        \.overlay\(alignment: \.topLeading\)",
            content,
        )
        self.assertIsNotNone(match, "未找到根级 .ignoresSafeArea + .overlay 链")
        self.assertEqual(match.group(1).strip(), ".container")
        self.assertNotIn(".ignoresSafeArea(.keyboard)", content)

    def test_onboarding_preserves_keyboard_safe_area(self) -> None:
        content = source("LifeMidpoint/Features/Onboarding/OnboardingStepView.swift")
        # 根级 modifier 链: 紧邻 tap-to-advance 注释之前的 ignoresSafeArea 必须且仅为 .container
        match = re.search(
            r"\n        \.ignoresSafeArea\(([^)]*)\)\n        // 仅在",
            content,
        )
        self.assertIsNotNone(match, "未找到根级 .ignoresSafeArea + tap-to-advance 注释链")
        self.assertEqual(match.group(1).strip(), ".container")
        self.assertNotIn(".ignoresSafeArea(.keyboard)", content)


class LoginKeyboardTests(unittest.TestCase):
    """Task 2: 登录页数字键盘完成按钮、滚动布局、字段焦点。"""

    def test_login_has_scroll_focus_and_keyboard_done_action(self) -> None:
        content = source("LifeMidpoint/Features/Auth/LoginView.swift")
        self.assertIn("@FocusState private var focusedField: Field?", content)
        self.assertIn("ScrollView(showsIndicators: false)", content)
        self.assertIn(".scrollDismissesKeyboard(.interactively)", content)
        self.assertIn("ToolbarItemGroup(placement: .keyboard)", content)
        self.assertIn(".focused($focusedField, equals: .phone)", content)
        self.assertIn(".focused($focusedField, equals: .code)", content)
        self.assertIn('Button("完成") { focusedField = nil }', content)


class EmotionKeyboardTests(unittest.TestCase):
    """Task 3: 情绪自定义输入各退出路径都收起键盘, 弹层支持下拉收起。"""

    def test_emotion_picker_dismisses_keyboard_from_all_exit_paths(self) -> None:
        picker = source("LifeMidpoint/Features/Diary/EmotionPickerSheet.swift")
        gate = source("LifeMidpoint/Features/Mind/EmotionRecognitionGate.swift")
        self.assertIn(".onSubmit { customFieldFocused = false }", picker)
        self.assertIn("customFieldFocused = false\n            let content =", picker)
        self.assertIn("customFieldFocused = false\n            if let onSkip", picker)
        self.assertIn(".scrollDismissesKeyboard(.interactively)", gate)


class LetterKeyboardTests(unittest.TestCase):
    """Task 4: 写信化名焦点 + 正文编辑交互式收起 + 键盘完成按钮。"""

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


class InputInventoryTests(unittest.TestCase):
    """Task 5: 全量输入点登记 + 日记页现有正确行为回归。"""

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
        self.assertIn(".ignoresSafeArea(.keyboard)", content)
        self.assertIn(".responsiveFill()", content)
        self.assertIn(".offset(y: keyboardHeight > 0 ? -keyboardHeight : 0)", content)
        self.assertIn("if keyboardHeight == 0", content)
        self.assertIn("UIResponder.keyboardWillChangeFrameNotification", content)
        self.assertIn("UIResponder.keyboardWillHideNotification", content)
        self.assertIn(".scrollDismissesKeyboard(.interactively)", content)
        self.assertIn(".onChange(of: isInputFocused)", content)
        self.assertIn("proxy.scrollTo(last, anchor: .bottom)", content)


if __name__ == "__main__":
    unittest.main()
