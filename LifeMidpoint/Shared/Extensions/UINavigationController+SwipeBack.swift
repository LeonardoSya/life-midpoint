import UIKit

/// 全局恢复"从屏幕左边缘向右滑动返回上一页"的系统手势。
///
/// 背景: 全 App 几乎每个全屏子页都用了 `.toolbar(.hidden, for: .navigationBar)`
/// 来隐藏系统导航栏、换成自定义 UI (见 `AppBackButton`)。但 UIKit 的
/// `UINavigationController` 默认逻辑是: 一旦没有系统返回按钮 (导航栏被隐藏或
/// `navigationBarBackButtonHidden(true)`), 就会自动把
/// `interactivePopGestureRecognizer` 禁用掉——这是苹果的私有默认行为，SwiftUI
/// 层面没有任何 API 能单独打开它。所以之前手动加的 `AppBackButton` 解决了
/// "按钮点不到"的问题，但边缘滑动返回一直是失效的。
///
/// 这里用业界通用的做法: 直接给 `UINavigationController` 这个类打一个 extension,
/// 覆盖它的 `viewDidLoad` 把手势的 delegate 接管为自己, 并在
/// `gestureRecognizerShouldBegin` 里只要求"栈里还有上一页可以返回"就放行——
/// 完全不管导航栏是否隐藏、是否有系统返回按钮。因为 SwiftUI 的 `NavigationStack`
/// 底层就是用 `UINavigationController` 实现的, 这一份 extension 对全 App
/// 所有页面自动生效, 不需要在每个页面单独处理。
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
