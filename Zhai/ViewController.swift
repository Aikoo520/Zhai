//
//  ViewController.swift
//  Zhai
//
//  Created by Айгерим Акылбекова on 06.08.2025.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Zhai"
        setupUI()
    }

    private func setupUI() {
        // Кнопка для перехода к экрану распознавания речи
        let speechButton = UIButton(type: .system)
        speechButton.setTitle(" Speech to Text", for: .normal)
        speechButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        speechButton.addTarget(self, action: #selector(openSpeechVC), for: .touchUpInside)

        // Кнопка для перехода к экрану распознавания жестов
        let signButton = UIButton(type: .system)
        signButton.setTitle(" Sign to Text", for: .normal)
        signButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        signButton.addTarget(self, action: #selector(openSignVC), for: .touchUpInside)

        // Стек с кнопками
        let stackView = UIStackView(arrangedSubviews: [speechButton, signButton])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openSpeechVC() {
        let vc = ViewController2()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openSignVC() {
        let vc = ViewController3()
        navigationController?.pushViewController(vc, animated: true)
    }
}
