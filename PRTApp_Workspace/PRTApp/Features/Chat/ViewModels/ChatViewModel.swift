//
//  ChatViewModel.swift
//  PRTApp_Workspace
//

import AVFoundation
import Foundation
import Observation
import Speech

@MainActor
@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var inputText = ""
    var isRecording = false
    var isLoading = false

    @ObservationIgnored
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "th-TH"))

    @ObservationIgnored
    private let audioEngine = AVAudioEngine()

    @ObservationIgnored
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?

    @ObservationIgnored
    private var recognitionTask: SFSpeechRecognitionTask?

    func sendMessage() async {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        messages.append(ChatMessage(text: trimmedText, isUser: true))
        inputText = ""
        isLoading = true

        try? await Task.sleep(for: .seconds(1.2))

        messages.append(ChatMessage(text: "ยอดค่าใช้จ่ายเดือนนี้คือ 450,000 บาทครับ", isUser: false))
        isLoading = false
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            Task { await requestAuthorizationAndStartRecording() }
        }
    }

    private func requestAuthorizationAndStartRecording() async {
        let speechStatus = await requestSpeechAuthorization()
        guard speechStatus == .authorized else {
            inputText = authorizationMessage(for: speechStatus)
            return
        }

        let isMicrophoneAllowed = await requestMicrophonePermission()
        guard isMicrophoneAllowed else {
            inputText = "Microphone access is required for voice input."
            return
        }

        do {
            try startRecording()
        } catch {
            inputText = "Unable to start voice input."
            stopRecording()
        }
    }

    private func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { isGranted in
                continuation.resume(returning: isGranted)
            }
        }
    }

    private func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        self.recognitionRequest = recognitionRequest

        guard let speechRecognizer, speechRecognizer.isAvailable else {
            inputText = "Speech recognizer is not available right now."
            return
        }

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self else { return }

                if let result {
                    self.inputText = result.bestTranscription.formattedString
                }

                if error != nil || result?.isFinal == true {
                    self.stopRecording()
                }
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1_024, format: recordingFormat) { [weak recognitionRequest] buffer, _ in
            recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
    }

    private func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func authorizationMessage(for status: SFSpeechRecognizerAuthorizationStatus) -> String {
        switch status {
        case .denied:
            "Speech recognition access was denied."
        case .restricted:
            "Speech recognition is restricted on this device."
        case .notDetermined:
            "Speech recognition is not authorized yet."
        case .authorized:
            ""
        @unknown default:
            "Speech recognition is not available."
        }
    }
}
