//
//  OpenAIService.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import Foundation
import UIKit
import Combine

class OpenAIService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        // TODO: Replace with your actual API key
        self.apiKey = "YOUR_OPENAI_API_KEY_HERE"
    }
    
    func detectObjects(in image: UIImage) async throws -> [DetectedObject] {
        isLoading = true
        errorMessage = nil
        
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw OpenAIError.invalidImage
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "List all visible objects in this image. Return a JSON array of objects with this exact format: [{\"name\": \"object name\", \"confidence\": 0.95, \"category\": \"category\"}]. Be specific and comprehensive. Include: furniture, electronics, food, decorations, people, etc. Categories should be: furniture, electronics, food, decoration, clothing, nature, people, or other."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]
        
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw OpenAIError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let errorMessage = (errorData?["error"] as? [String: Any])?["message"] as? String ?? "Unknown error"
            throw OpenAIError.apiError(errorMessage)
        }
        
        let responseData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = responseData?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.invalidResponse
        }
        
        return try parseDetectedObjects(from: content)
    }
    
    private func parseDetectedObjects(from jsonString: String) throws -> [DetectedObject] {
        // Clean the JSON string (remove markdown formatting if present)
        let cleanJSON = jsonString
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanJSON.data(using: .utf8) else {
            throw OpenAIError.parsingError
        }
        
        let objects = try JSONDecoder().decode([DetectedObjectResponse].self, from: data)
        
        return objects.map { obj in
            DetectedObject(
                name: obj.name,
                confidence: obj.confidence,
                category: DetectedObject.ObjectCategory(rawValue: obj.category) ?? .other
            )
        }
    }
}

// MARK: - Response Models
private struct DetectedObjectResponse: Codable {
    let name: String
    let confidence: Double
    let category: String
}

// MARK: - Error Handling
enum OpenAIError: LocalizedError {
    case invalidImage
    case invalidURL
    case encodingError
    case invalidResponse
    case apiError(String)
    case parsingError
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image data"
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError:
            return "Failed to encode request"
        case .invalidResponse:
            return "Invalid API response"
        case .apiError(let message):
            return "API Error: \(message)"
        case .parsingError:
            return "Failed to parse response"
        }
    }
}
