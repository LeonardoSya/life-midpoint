import AVFoundation
import Speech

/// 语音转文字服务, 供"写信"页的麦克风按钮使用.
///
/// 基于系统 `Speech` + `AVAudioEngine`: 边说边把识别到的文字通过 `onTranscript`
/// 回调出去, 由调用方决定如何拼接进正文。停止时会自动清理音频会话。
@MainActor
final class VoiceDictationService: ObservableObject {
    @Published private(set) var isRecording = false
    @Published var errorMessage: String?

    /// 每次识别结果更新时回调最新的完整转写文本 (同一段录音内会不断被替换, 不是追加).
    var onTranscript: ((String) -> Void)?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func toggle() {
        if isRecording {
            stop()
        } else {
            start()
        }
    }

    func start() {
        guard !isRecording else { return }
        errorMessage = nil

        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            AVAudioApplication.requestRecordPermission { granted in
                Task { @MainActor in
                    guard let self else { return }
                    guard authStatus == .authorized, granted else {
                        self.errorMessage = "需要麦克风和语音识别权限才能语音写信"
                        return
                    }
                    self.beginRecording()
                }
            }
        }
    }

    private func beginRecording() {
        guard let recognizer, recognizer.isAvailable else {
            errorMessage = "当前设备暂不支持语音识别"
            return
        }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "无法启动录音, 请稍后重试"
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            errorMessage = "无法启动录音, 请稍后重试"
            cleanupAudio()
            return
        }

        isRecording = true

        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    self.onTranscript?(result.bestTranscription.formattedString)
                }
                if error != nil || result?.isFinal == true {
                    self.stop()
                }
            }
        }
    }

    func stop() {
        guard isRecording || audioEngine.isRunning else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
        cleanupAudio()
        isRecording = false
    }

    private func cleanupAudio() {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
