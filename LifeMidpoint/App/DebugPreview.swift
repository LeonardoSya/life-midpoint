import SwiftUI

#if DEBUG
enum DebugPreviewMode: String, CaseIterable {
    case normal = "Normal"
    case main = "Main"
    case login = "Login"
    case onboarding = "Onboarding"
    case diary = "Diary"
    case diaryReview = "DiaryReview"
    case diaryReviewEmpty = "DiaryReviewEmpty"
    case diaryLoading = "DiaryLoading"
    case postOffice = "PostOffice"
    case writeLetter = "WriteLetter"
    case writeLetterDefault = "WriteLetterDefault"
    case letterShowcase = "LetterShowcase"
    case letterSent = "LetterSent"
    case monthlyReport = "MonthlyReport"
    case penPalList = "PenPalList"
    case penPalDetail = "PenPalDetail"
    case stampAlbum = "StampAlbum"
    case stampShowcase = "StampShowcase"
    case stampObtained = "StampObtained"
    case mind = "Mind"
    case breathing = "Breathing"
    case microBehavior = "MicroBehavior"
    case microEmotionStart = "MicroEmotionStart"
    case microEmotionEnd = "MicroEmotionEnd"
    case psychologyCard = "PsychologyCard"
    case knowledgeBase = "KnowledgeBase"
    case health = "Health"
    case periodTracking = "PeriodTracking"
    case symptomTracking = "SymptomTracking"
    case symptomDetail = "SymptomDetail"
    case sleep = "Sleep"
    case heartRate = "HeartRate"
    case healthSummary = "HealthSummary"
    case medicationRecord = "MedicationRecord"
    case medicationReminder = "MedicationReminder"
    case editReminder = "EditReminder"
    case myMedications = "MyMedications"
    case settings = "Settings"
    case weeklySummary = "WeeklySummary"
    case emotionPicker = "EmotionPicker"
    case emotionDetail = "EmotionDetail"
    case diarySummary = "DiarySummary"
}

enum DebugPreview {
    static var mode: DebugPreviewMode {
        let raw = ProcessInfo.processInfo.environment["DEBUG_PREVIEW"] ?? "Normal"
        return DebugPreviewMode(rawValue: raw) ?? .normal
    }
}
#endif
