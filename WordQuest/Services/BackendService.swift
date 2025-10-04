//
//  BackendService.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import Foundation
import UIKit
import Combine

struct BackendAnalysis: Codable {
    let question: String
    let native_language: String
    let target_language: String
}

class BackendService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://10.248.113.69:8000" // Your machine's IP address
    
    init() {
        print("🚀 BackendService initialized - using FastAPI backend for image analysis!")
    }
    
    func analyzeImage(_ image: UIImage, nativeLanguage: String, targetLanguage: String) async throws -> BackendAnalysis {
        isLoading = true
        errorMessage = nil
        
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        print("🚀 Starting personalized language learning analysis...")
        print("📊 Image size: \(image.size)")
        print("🌍 Native Language: \(nativeLanguage)")
        print("🎯 Target Language: \(targetLanguage)")
        
        // Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw BackendError.invalidImage
        }
        
        print("📊 Image data size: \(imageData.count) bytes")
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add native language
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"native_language\"\r\n\r\n".data(using: .utf8)!)
        body.append(nativeLanguage.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add target language
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"target_language\"\r\n\r\n".data(using: .utf8)!)
        body.append(targetLanguage.data(using: .utf8)!)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Create request
        guard let url = URL(string: "\(baseURL)/analyze-image") else {
            throw BackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        print("📡 Sending request to backend...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("📡 Backend response received")
        print("📊 Response size: \(data.count) bytes")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response format")
            throw BackendError.invalidResponse
        }
        
        print("🔢 HTTP Status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Backend Error: \(errorMessage)")
            throw BackendError.serverError(errorMessage)
        }
        
        do {
            let analysis = try JSONDecoder().decode(BackendAnalysis.self, from: data)
            print("✅ Personalized language learning question generated!")
            print("📝 Question length: \(analysis.question.count) characters")
            print("==================================================================================")
            print("🎓 LANGUAGE LEARNING QUESTION:")
            print("==================================================================================")
            print(analysis.question)
            print("==================================================================================")
            print("🌍 Native: \(analysis.native_language)")
            print("🎯 Target: \(analysis.target_language)")
            print("==================================================================================")
            return analysis
        } catch {
            print("❌ Failed to decode response: \(error)")
            throw BackendError.invalidResponse
        }
    }
}

enum BackendError: Error, LocalizedError {
    case invalidURL
    case invalidImage
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The backend URL is invalid."
        case .invalidImage: return "Could not process the image for analysis."
        case .invalidResponse: return "Invalid response from backend."
        case .serverError(let message): return "Backend Error: \(message)"
        }
    }
}
