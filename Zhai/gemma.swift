//
//  gemma.swift
//  Zhai
//
//  Created by Айгерим Акылбекова on 06.08.2025.
//

import Foundation

class GemmaService {
    private let baseURL = URL(string: "http://localhost:11434")!

    func generate(prompt: String, completion: @escaping (String?) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("completions"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gemma-2b",
            "prompt": prompt,
            "max_tokens": 100
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let first = choices.first,
                  let output = first["text"] as? String else {
                completion(nil)
                return
            }
            completion(output.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }
}

