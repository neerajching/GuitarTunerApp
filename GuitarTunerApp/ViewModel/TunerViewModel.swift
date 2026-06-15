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

    var isListening = false

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
