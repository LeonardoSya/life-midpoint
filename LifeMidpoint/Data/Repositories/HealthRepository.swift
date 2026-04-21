import Foundation
import SwiftData

/// 健康模块仓储 (睡眠 / 心率 / 症状 / 经期 / 用药).
@MainActor
struct HealthRepository {
    let context: ModelContext

    // MARK: - 睡眠

    /// 写入或更新某天的睡眠数据 (按日 unique).
    @discardableResult
    func upsertSleep(date: Date, totalMinutes: Int, deep: Int = 0,
                     light: Int = 0, rem: Int = 0,
                     score: Int = 0, note: String? = nil) -> SleepDay {
        let key = DayKey.key(for: date)
        let predicate = #Predicate<SleepDay> { $0.dayKey == key }
        if let existing = try? context.fetch(FetchDescriptor<SleepDay>(predicate: predicate)).first {
            existing.totalMinutes = totalMinutes
            existing.deepMinutes = deep
            existing.lightMinutes = light
            existing.remMinutes = rem
            existing.qualityScore = score
            existing.qualityNote = note
            try? context.save()
            return existing
        }
        let day = SleepDay(date: date, totalMinutes: totalMinutes,
                           deepMinutes: deep, lightMinutes: light, remMinutes: rem,
                           qualityScore: score, qualityNote: note)
        context.insert(day)
        try? context.save()
        return day
    }

    func recentSleep(days: Int = 7) -> [SleepDay] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let predicate = #Predicate<SleepDay> { $0.date >= cutoff }
        let d = FetchDescriptor<SleepDay>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? context.fetch(d)) ?? []
    }

    // MARK: - 心率

    @discardableResult
    func upsertHeartRate(date: Date, bpm: Int) -> HeartRateDay {
        let key = DayKey.key(for: date)
        let predicate = #Predicate<HeartRateDay> { $0.dayKey == key }
        if let existing = try? context.fetch(FetchDescriptor<HeartRateDay>(predicate: predicate)).first {
            existing.restingBpm = bpm
            try? context.save()
            return existing
        }
        let entry = HeartRateDay(date: date, restingBpm: bpm)
        context.insert(entry)
        try? context.save()
        return entry
    }

    func recentHeartRate(days: Int = 7) -> [HeartRateDay] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let predicate = #Predicate<HeartRateDay> { $0.date >= cutoff }
        let d = FetchDescriptor<HeartRateDay>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? context.fetch(d)) ?? []
    }

    // MARK: - 症状

    /// 当天的症状列表 (按插入顺序).
    func todaySymptoms() -> [SymptomLog] {
        let today = Calendar.current.startOfDay(for: Date())
        let predicate = #Predicate<SymptomLog> { $0.date == today }
        let d = FetchDescriptor<SymptomLog>(predicate: predicate)
        return (try? context.fetch(d)) ?? []
    }

    /// 调整某条症状的严重度 (UI 上的 1/2/3 圆点).
    func updateSeverity(_ symptom: SymptomLog, severity: Int) {
        symptom.severity = max(0, min(3, severity))
        try? context.save()
    }

    func deleteSymptom(_ symptom: SymptomLog) {
        context.delete(symptom)
        try? context.save()
    }

    // MARK: - 经期

    @discardableResult
    func addPeriod(start: Date, end: Date? = nil) -> MenstrualPeriod {
        let p = MenstrualPeriod(startDate: start, endDate: end)
        context.insert(p)
        try? context.save()
        return p
    }

    func allPeriods() -> [MenstrualPeriod] {
        let d = FetchDescriptor<MenstrualPeriod>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return (try? context.fetch(d)) ?? []
    }

    // MARK: - 用药

    func allMedications() -> [Medication] {
        let d = FetchDescriptor<Medication>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return (try? context.fetch(d)) ?? []
    }

    /// 当天的服药事件. 没有则按药品默认提醒时间一次性创建当日事件.
    func todayDoseEvents() -> [MedicationDoseEvent] {
        let today = Calendar.current.startOfDay(for: Date())
        let predicate = #Predicate<MedicationDoseEvent> { $0.date == today }
        let d = FetchDescriptor<MedicationDoseEvent>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.scheduledTime, order: .forward)]
        )
        let existing = (try? context.fetch(d)) ?? []
        if !existing.isEmpty { return existing }

        // Bootstrap: 当天还没有事件 -> 按药品默认时间生成
        let meds = allMedications()
        for med in meds {
            guard let time = med.defaultReminderTime else { continue }
            context.insert(MedicationDoseEvent(date: today, scheduledTime: time,
                                               taken: false, medication: med))
        }
        try? context.save()
        return (try? context.fetch(d)) ?? []
    }

    /// 切换某次服药事件的勾选状态.
    func toggleDose(_ event: MedicationDoseEvent) {
        event.taken.toggle()
        try? context.save()
    }
}
