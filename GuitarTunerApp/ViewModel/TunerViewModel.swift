//
//  TunerViewModel.swift
//  GuitarTunerApp
//
//  Created by Negi on 16/06/26.
//
import Foundation
import Observation

@Observable
final class TunerViewModel {

    private let audioManager = AudioEngineManager()
    
    
    var rms: Float = 0
//    var sampleRate: Double = 0
//    var sampleCount: Int = 0
    var isListening = false
    var detectedFrequency: Double?

    init() {
        audioManager.onSnapshot = { [weak self] snapshot in
            let freq = ZeroCrossingPitchDetector.detectFrequency(
                            samples: snapshot.samples,
                            sampleRate: snapshot.sampleRate,
                            rms: snapshot.rms)
                           
            DispatchQueue.main.async {
                self?.rms = snapshot.rms
                self?.detectedFrequency = freq

                if let freq {
                    print("🎵 \(Int(freq)) Hz")
                }
            }
        }
    }
    func requestPermission() {
        audioManager.requestMicrophonePermission()
    }

    func startListening() {

        do {
            try audioManager.start()
            isListening = true
        } catch {
            print("❌ Failed to start audio engine")
            print(error.localizedDescription)
        }
    }

    func stopListening() {
        audioManager.stop()
        isListening = false
    }
}
