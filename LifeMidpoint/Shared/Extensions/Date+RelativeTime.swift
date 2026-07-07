import Foundation

extension Date {
    /// 简洁的中文相对时间描述, 例如"2小时前"、"昨天"。用于信件卡片等"发生了多久"的展示场景。
    func relativeChineseDescription(relativeTo reference: Date = Date()) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: reference)
    }
}
