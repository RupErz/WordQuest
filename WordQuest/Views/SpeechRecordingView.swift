//
//  SpeechRecordingView.swift
//  LanguageVision
//
//  Created by Nghia Vu on 10/4/25.
//

import SwiftUI
import Speech
import AVFoundation

struct SpeechRecordingView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var isRecording = false
    @State private var recordedText = ""
    @State private var timeRemaining: Double = 0
    @State private var timer: Timer?
    @State private var showingWinPopup = false
    @State private var showingLosePopup = false
    @State private var gameResult: GameResult = .none
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var isTTSPlaying = false
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    // Data from previous screens
    let selectedPhoto: PhotoData
    let question: String
    let correctAnswer: String
    let translation: String
    let nativeLanguage: String
    let targetLanguage: String
    
    // Navigation callback
    let onBackToPhotoSelection: () -> Void
    
    enum GameResult {
        case none, win, lose
    }
    
    var body: some View {
        ZStack {
            // Background Image
            if let uiImage = selectedPhoto.thumbnail {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                // Fallback background if image not available
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.05),
                        Color.teal.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            VStack {
                Spacer()
                
                // Question and Translation Overlay
                VStack(alignment: .center, spacing: 15) {
                    Text("Your Language Challenge:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    
                    Text(question)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(radius: 8)
                    
                    // Translation Display
                    if !translation.isEmpty {
                        Text(translation)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .shadow(radius: 3)
                    }
                    
                    HStack {
                        Text("🌍 Native: \(nativeLanguage)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(radius: 2)
                        Spacer()
                        Text("🎯 Target: \(targetLanguage)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 30)
                .background(
                    .ultraThinMaterial
                        .opacity(0.8)
                )
                .cornerRadius(20)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Recording Controls (center)
                VStack(spacing: 15) {
                    if isRecording {
                        VStack(spacing: 12) {
                            RecordingAnimationView()
                            
                            // Timer Display
                            Text("Time: \(String(format: "%.1f", timeRemaining))s")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                            
                            // Stop Button
                            Button(action: {
                                stopRecording()
                            }) {
                                HStack {
                                    Image(systemName: "stop.fill")
                                    Text("Stop & Check Answer")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [.red, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    } else {
                        VStack(spacing: 12) {
                            Text("Ready to Record?")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                            
                            StartRecordingButton {
                                startRecording()
                            }
                        }
                    }
                    
                    // Live Transcription (bottom)
                    if !recordedText.isEmpty {
                        VStack(spacing: 8) {
                            Text("You said:")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                            
                            Text(recordedText)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(.ultraThinMaterial.opacity(0.8))
                                .cornerRadius(12)
                                .shadow(radius: 3)
                        }
                    }
                }
                
                Spacer()
                
                // Help Button
                Button("I need help") {
                    // Show hints
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            setupTimer()
            requestMicrophonePermission()
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $showingWinPopup) {
            WinPopupView(
                onTryMore: {
                    showingWinPopup = false
                    onBackToPhotoSelection()
                }
            )
        }
        .sheet(isPresented: $showingLosePopup) {
            LosePopupView(
                correctAnswer: correctAnswer,
                targetLanguage: targetLanguage,
                onTryAgain: {
                    showingLosePopup = false
                    resetGame()
                }
            )
        }
    }
    
    private func setupTimer() {
        let duration = getTimerDuration()
        timeRemaining = duration
    }
    
    private func getTimerDuration() -> Double {
        switch userPreferences.difficultyLevel {
        case .beginner: return 15.0
        case .intermediate: return 10.0
        case .advanced: return 5.0
        }
    }
    
    private func startRecording() {
        isRecording = true
        startTimer()
        startSpeechRecognition()
    }
    
    private func stopRecording() {
        isRecording = false
        stopTimer()
        stopSpeechRecognition()
        checkAnswer()
    }
    
    private func startSpeechRecognition() {
        // Stop any existing recognition
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure for target language
        if let recognizer = SFSpeechRecognizer(locale: Locale(identifier: getLanguageCode(for: targetLanguage))) {
            speechRecognizer = recognizer
        }
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self.recordedText = result.bestTranscription.formattedString
                }
                
                if error != nil || result?.isFinal == true {
                    self.stopSpeechRecognition()
                }
            }
        }
        
        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    private func stopSpeechRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                // Time's up!
                stopRecording()
                gameResult = .lose
                showingLosePopup = true
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkAnswer() {
        let userAnswer = recordedText.lowercased().trimmingCharacters(in: .whitespaces)
        let correct = correctAnswer.lowercased().trimmingCharacters(in: .whitespaces)
        
        if userAnswer == correct {
            gameResult = .win
            showingWinPopup = true
        } else {
            gameResult = .lose
            showingLosePopup = true
        }
    }
    
    private func resetGame() {
        timeRemaining = getTimerDuration()
        recordedText = ""
        isRecording = false
        gameResult = .none
    }
    
    private func getLanguageCode(for language: String) -> String {
        switch language.lowercased() {
        case "english": return "en-US"
        case "spanish": return "es-ES"
        case "french": return "fr-FR"
        case "german": return "de-DE"
        case "japanese": return "ja-JP"
        case "chinese": return "zh-CN"
        case "korean": return "ko-KR"
        case "italian": return "it-IT"
        case "portuguese": return "pt-PT"
        case "russian": return "ru-RU"
        case "arabic": return "ar-SA"
        case "hindi": return "hi-IN"
        default: return "en-US"
        }
    }
    
    private func requestMicrophonePermission() {
        Task {
            let granted = await AVAudioApplication.requestRecordPermission()
            await MainActor.run {
                if granted {
                    print("🎤 Microphone permission granted")
                } else {
                    print("❌ Microphone permission denied")
                }
            }
        }
    }
}

struct StartRecordingButton: View {
    let onStart: () -> Void
    
    var body: some View {
        Button(action: onStart) {
            VStack(spacing: 15) {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Start Recording")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [.blue, .green],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct RecordingAnimationView: View {
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Pulsing circles
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 4)
                        .frame(width: 100 + CGFloat(index * 20), height: 100 + CGFloat(index * 20))
                        .scaleEffect(1 + animationPhase * 0.3)
                        .opacity(1 - animationPhase)
                }
                
                // Main microphone
                Image(systemName: "mic.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    animationPhase = 1.0
                }
            }
            
            Text("Listening...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.red)
        }
    }
}

struct WinPopupView: View {
    let onTryMore: () -> Void
    @State private var showFireworks = false
    
    var body: some View {
        ZStack {
            // Fireworks background
            if showFireworks {
                FireworksView()
            }
            
            VStack(spacing: 30) {
                // Congratulations
                VStack(spacing: 15) {
                    Text("🎉")
                        .font(.system(size: 60))
                    
                    Text("Congratulations!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("You got it right!")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                
                // Try More Button
                Button(action: onTryMore) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try More")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .onAppear {
            showFireworks = true
        }
    }
}

struct LosePopupView: View {
    let correctAnswer: String
    let targetLanguage: String
    let onTryAgain: () -> Void
    @State private var isPlayingTTS = false
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var ttsDelegate: TTSDelegate?
    
    var body: some View {
        VStack(spacing: 30) {
            // You Lost
            VStack(spacing: 15) {
                Text("😔")
                    .font(.system(size: 60))
                
                Text("You lost :(")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.red)
                
                Text("The correct answer was: \(correctAnswer)")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            }
            
            // Pronunciation Guide
            VStack(spacing: 15) {
                Text("Pronunciation Guide")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Button(action: {
                    playPronunciation()
                }) {
                    HStack {
                        Image(systemName: isPlayingTTS ? "speaker.wave.2.fill" : "speaker.wave.2")
                        Text(isPlayingTTS ? "Playing..." : "Listen to pronunciation")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            // Try Again Button
            Button(action: onTryAgain) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        colors: [.red, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func playPronunciation() {
        guard !isPlayingTTS else { return }
        
        isPlayingTTS = true
        
        // Stop any current speech
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        
        // Create a new synthesizer to avoid delegate issues
        let newSynthesizer = AVSpeechSynthesizer()
        
        let utterance = AVSpeechUtterance(string: correctAnswer)
        utterance.voice = AVSpeechSynthesisVoice(language: getLanguageCode(for: targetLanguage))
        utterance.rate = 0.6
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Use delegate to detect when speech finishes
        ttsDelegate = TTSDelegate {
            DispatchQueue.main.async {
                isPlayingTTS = false
            }
        }
        newSynthesizer.delegate = ttsDelegate
        
        newSynthesizer.speak(utterance)
        
        // Update the synthesizer reference
        synthesizer = newSynthesizer
    }
    
    private func getLanguageCode(for language: String) -> String {
        switch language.lowercased() {
        case "english": return "en-US"
        case "spanish": return "es-ES"
        case "french": return "fr-FR"
        case "german": return "de-DE"
        case "japanese": return "ja-JP"
        case "chinese": return "zh-CN"
        case "korean": return "ko-KR"
        case "italian": return "it-IT"
        case "portuguese": return "pt-PT"
        case "russian": return "ru-RU"
        case "arabic": return "ar-SA"
        case "hindi": return "hi-IN"
        default: return "en-US"
        }
    }
}

// TTS Delegate to handle speech completion
class TTSDelegate: NSObject, AVSpeechSynthesizerDelegate {
    private let onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        onFinish()
    }
}

struct FireworksView: View {
    @State private var particles: [FireworkParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            startFireworks()
        }
    }
    
    private func startFireworks() {
        for _ in 0..<50 {
            let particle = FireworkParticle()
            particles.append(particle)
        }
    }
}

struct FireworkParticle {
    let id = UUID()
    let position: CGPoint
    let color: Color
    let size: CGFloat
    let opacity: Double
    
    init() {
        self.position = CGPoint(
            x: CGFloat.random(in: 0...400),
            y: CGFloat.random(in: 0...600)
        )
        self.color = [Color.red, Color.blue, Color.green, Color.yellow, Color.purple].randomElement() ?? .red
        self.size = CGFloat.random(in: 4...12)
        self.opacity = Double.random(in: 0.3...1.0)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

#Preview(windowStyle: .automatic) {
    SpeechRecordingView(
        selectedPhoto: PhotoData(
            assetIdentifier: "test",
            thumbnail: nil,
            creationDate: Date(),
            isSelected: false
        ),
        question: "There is a tall _____ in the middle of the picture.",
        correctAnswer: "tree",
        translation: "There is a tall tree in the middle of the picture.",
        nativeLanguage: "English",
        targetLanguage: "Spanish",
        onBackToPhotoSelection: {}
    )
    .environmentObject(UserPreferences())
}