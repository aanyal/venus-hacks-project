//
//  SpeechTranscriptionService.swift
//  VenusHacksProject
//

import AVFAudio
import Foundation
import Speech

final class SpeechTranscriptionService: NSObject {
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: .current)
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var transcriptUpdate: ((String) -> Void)?
    private var currentTranscript = ""
    private var stopContinuation: CheckedContinuation<String, Error>?
    private var isStopping = false

    var isRecording: Bool {
        audioEngine.isRunning
    }

    func start(transcriptUpdate: @escaping (String) -> Void) async throws {
        try await requestPermissionsIfNeeded()

        if isRecording {
            recognitionTask?.cancel()
            recognitionTask = nil
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        self.transcriptUpdate = transcriptUpdate
        currentTranscript = ""
        isStopping = false
        speechRecognizer = SFSpeechRecognizer(locale: .current)

        guard let speechRecognizer else {
            throw SpeechTranscriptionError.unavailableRecognizer
        }

        guard speechRecognizer.isAvailable else {
            throw SpeechTranscriptionError.recognizerUnavailable
        }

        try configureRecordingSession()

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if #available(iOS 13, macOS 10.15, *) {
            request.requiresOnDeviceRecognition = false
        }
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result {
                let transcript = result.bestTranscription.formattedString
                self.currentTranscript = transcript
                DispatchQueue.main.async {
                    self.transcriptUpdate?(transcript)
                }

                if self.isStopping, result.isFinal {
                    self.finishStop(with: transcript)
                }
            }

            if let error {
                if self.isStopping {
                    self.finishStop(with: self.currentTranscript)
                } else {
                    self.cleanupRecognition()
                    if let stopContinuation = self.stopContinuation {
                        stopContinuation.resume(throwing: error)
                        self.stopContinuation = nil
                    }
                }
            }
        }
    }

    func stop() async throws -> String {
        guard isRecording else {
            return currentTranscript
        }

        isStopping = true
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()

        return try await withCheckedThrowingContinuation { continuation in
            stopContinuation = continuation

            Task { [weak self] in
                try? await Task.sleep(for: .milliseconds(450))
                guard let self, self.stopContinuation != nil else { return }
                self.finishStop(with: self.currentTranscript)
            }
        }
    }

    func cancel() {
        cleanupRecognition()
        stopContinuation?.resume(returning: currentTranscript)
        stopContinuation = nil
    }

    private func finishStop(with transcript: String) {
        cleanupRecognition()
        stopContinuation?.resume(returning: transcript)
        stopContinuation = nil
    }

    private func cleanupRecognition() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isStopping = false
        transcriptUpdate = nil
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)

        #if os(iOS) || os(visionOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    private func configureRecordingSession() throws {
        #if os(iOS) || os(visionOS)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        #endif
    }

    private func requestPermissionsIfNeeded() async throws {
        let recordGranted = await AVAudioApplication.requestRecordPermission()
        guard recordGranted else {
            throw SpeechTranscriptionError.microphonePermissionDenied
        }

        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        if speechStatus == .authorized { return }

        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { authorizationStatus in
                continuation.resume(returning: authorizationStatus)
            }
        }

        guard status == .authorized else {
            throw SpeechTranscriptionError.speechPermissionDenied
        }
    }
}

enum SpeechTranscriptionError: LocalizedError {
    case unavailableRecognizer
    case recognizerUnavailable
    case microphonePermissionDenied
    case speechPermissionDenied

    var errorDescription: String? {
        switch self {
        case .unavailableRecognizer:
            return "Speech recognition is not available for the current device language."
        case .recognizerUnavailable:
            return "Speech recognition is temporarily unavailable. Try again in a moment."
        case .microphonePermissionDenied:
            return "Microphone access is required for Tap To Speak."
        case .speechPermissionDenied:
            return "Speech recognition access is required for Tap To Speak."
        }
    }
}
