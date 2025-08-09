//
//  Speechtotext.swift
//  Zhai
//
//  Created by Айгерим Акылбекова on 06.08.2025.
//

import Foundation
import Speech

class SpeechToTextService {
    func transcribe(audioURL: URL, completion: @escaping (String?) -> Void) {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
        let request = SFSpeechURLRecognitionRequest(url: audioURL)

        recognizer.recognitionTask(with: request) { result, error in
            if let result = result, result.isFinal {
                completion(result.bestTranscription.formattedString)
            } else if error != nil {
                completion(nil)
            }
        }
    }
}


