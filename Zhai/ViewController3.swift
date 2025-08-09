//
//  ViewController3.swift
//  Zhai
//
//  Created by Айгерим Акылбекова on 06.08.2025.
//

import UIKit
import AVFoundation

class ViewController3: UIViewController {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let label = UILabel()
    private let responseLabel = UILabel()
    private let speechSynthesizer = AVSpeechSynthesizer()
    var currentPhrase: [String] = []
    private var gemmaResponseTextView: UITextView!
    

    let gestureWords: [(emoji: String, text: String)] = [
        ("👋", "Привет"), ("🙏", "Спасибо"), ("👍", "Да"), ("👎", "Нет"),
        ("😢", "Грусть"), ("😂", "Смех"), ("😡", "Злость"), ("😎", "Круто"),
        ("🤝", "Познакомиться"), ("🤗", "Объятие"), ("🚫", "Нельзя"), ("👌", "Отлично"),
        ("✌️", "Пока"), ("🤙", "Связаться"), ("🫶", "Любовь"), ("💪", "Сила"),
        ("👂", "Слушаю"), ("🧏", "Я глухой"), ("👨‍👩‍👧", "Семья"), ("👶", "Ребенок"),
        ("🛑", "Стоп"), ("🤷", "Не знаю"), ("🙋", "Я хочу"), ("🙇", "Прошу прощения"),
        ("📱", "Телефон"), ("📞", "Позвони"), ("🏃", "Бежать"), ("🚶", "Идти"),
        ("💤", "Спать"), ("🍽️", "Есть"), ("🥤", "Пить"), ("🎉", "Праздник"),
        ("🎁", "Подарок"), ("📚", "Учеба"), ("🏫", "Школа"), ("💼", "Работа"),
        ("💊", "Лекарство"), ("🏥", "Больница"), ("🚗", "Машина"), ("✈️", "Самолет"),
        ("🚌", "Автобус"), ("⌚", "Время"), ("⏰", "Будильник"), ("📅", "Календарь"),
        ("💬", "Говорить"), ("🔇", "Тишина"), ("🔊", "Громко"), ("🆘", "Помощь"),
        ("🆗", "Хорошо"), ("🙌", "Ура")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Sign to Text"


        setupCameraPreview()
        addOverlayLabel()
        addGestureEmojiPanel()
        addResponseLabel()
        addSendButton()
        startCameraSession()
        setupGemmaResponseTextView()
    }
    private func setupGemmaResponseTextView() {
        gemmaResponseTextView = UITextView()
        gemmaResponseTextView.translatesAutoresizingMaskIntoConstraints = false
        gemmaResponseTextView.font = .systemFont(ofSize: 18)
        gemmaResponseTextView.textColor = .white
        gemmaResponseTextView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        gemmaResponseTextView.isEditable = false
        gemmaResponseTextView.isSelectable = false
        gemmaResponseTextView.textAlignment = .center
        gemmaResponseTextView.text = "Ответ ИИ появится здесь"

        view.addSubview(gemmaResponseTextView)

        NSLayoutConstraint.activate([
            gemmaResponseTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            gemmaResponseTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            gemmaResponseTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            gemmaResponseTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }


    private func addResponseLabel() {
        responseLabel.text = "Ответ AI будет здесь"
        responseLabel.font = .systemFont(ofSize: 18)
        responseLabel.textColor = .systemYellow
        responseLabel.numberOfLines = 0
        responseLabel.textAlignment = .center
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(responseLabel)

        NSLayoutConstraint.activate([
            responseLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            responseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            responseLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func addSendButton() {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("➤ Отправить", for: .normal)
        sendButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.layer.cornerRadius = 10
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendToGemma), for: .touchUpInside)

        view.addSubview(sendButton)
        NSLayoutConstraint.activate([
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 180),
            sendButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupCameraPreview() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera),
              captureSession?.canAddInput(input) == true else {
            print("Ошибка доступа к камере")
            return
        }

        captureSession?.addInput(input)
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        if let preview = previewLayer {
            view.layer.insertSublayer(preview, at: 0)
        }
    }

    private func addOverlayLabel() {
        label.text = "Выберите жест"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -140),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
    }

    private func addGestureEmojiPanel() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = true

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stackView)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.heightAnchor.constraint(equalToConstant: 70),

            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        for (emoji, text) in gestureWords {
            let button = UIButton(type: .system)
            button.setTitle(emoji, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 36)
            button.addAction(UIAction(handler: { _ in
                self.handleEmojiTapped(text)
            }), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    private func handleEmojiTapped(_ text: String) {
        currentPhrase.append(text)
        label.text = currentPhrase.joined(separator: " ")
    }

    @objc private func sendToGemma() {
        let phrase = currentPhrase.joined(separator: " ")
        guard !phrase.isEmpty else { return }
        askGemma(phrase)
        currentPhrase.removeAll()
        label.text = "Выберите жест"
    }

    private func startCameraSession() {
        captureSession?.startRunning()
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }

    private func askGemma(_ userText: String) {
        guard let url = URL(string: "http://192.168.1.2:8000/ask") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = ["prompt": "Пользователь выразил: \(userText). Ответь поддержкой или реакцией."]

        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Ошибка запроса к Gemma: \(error)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                  let reply = json["response"] else {
                print("Ошибка разбора ответа")
                return
            }

            DispatchQueue.main.async {
                self.gemmaResponseTextView.text = reply
                self.speak(reply)
            }
        }

        task.resume()
    }

}
