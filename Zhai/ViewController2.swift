//
//  ViewController2.swift
//  Zhai
//
//  Created by Айгерим Акылбекова on 06.08.2025.
//

import UIKit
import AVFoundation
import Speech

class ViewController2: UIViewController{
    private let transcriptLabel = UITextView()
        private let recordButton = UIButton(type: .system)

        private let audioEngine = AVAudioEngine()
        private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        private var recognitionTask: SFSpeechRecognitionTask?
        private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Speech to Text"
        setupUI()
        requestPermissions()
    }
    

    private func setupUI() {
            transcriptLabel.font = .systemFont(ofSize: 18)
            transcriptLabel.isEditable = false
            transcriptLabel.layer.borderWidth = 1
            transcriptLabel.layer.borderColor = UIColor.gray.cgColor
            transcriptLabel.layer.cornerRadius = 10
            transcriptLabel.translatesAutoresizingMaskIntoConstraints = false

            recordButton.setTitle("🎤 Start Recording", for: .normal)
            recordButton.titleLabel?.font = .systemFont(ofSize: 18)
            recordButton.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
            recordButton.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(transcriptLabel)
            view.addSubview(recordButton)

            NSLayoutConstraint.activate([
                recordButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                transcriptLabel.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 20),
                transcriptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                transcriptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                transcriptLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ])
        }

        private func requestPermissions() {
            SFSpeechRecognizer.requestAuthorization { _ in }
            AVAudioSession.sharedInstance().requestRecordPermission { _ in }
        }

        @objc private func toggleRecording() {
            if audioEngine.isRunning {
                stopRecording()
                recordButton.setTitle("🎤 Start Recording", for: .normal)
            } else {
                startRecording()
                recordButton.setTitle("⏹ Stop Recording", for: .normal)
            }
        }

        private func startRecording() {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("Audio session setup failed: \(error)")
                return
            }

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            recognitionRequest?.shouldReportPartialResults = true

            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try? audioEngine.start()

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: { result, error in
                guard let result = result else { return }
                DispatchQueue.main.async {
                    self.transcriptLabel.text = result.bestTranscription.formattedString
                }
            })
        }

        private func stopRecording() {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
            recognitionRequest = nil
            recognitionTask = nil
        }
    }
