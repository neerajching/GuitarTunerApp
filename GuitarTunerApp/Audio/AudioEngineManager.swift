//
//  AudioEngineManager.swift
//  GuitarTunerApp
//
//  Created by Negi on 16/06/26.
//
import Foundation
import AVFoundation

final class AudioEngineManager {

    private let audioEngine = AVAudioEngine()

    func requestMicrophonePermission() {
        AVAudioApplication.requestRecordPermission { granted in
            print("🎤 Permission granted: \(granted)")
        }
    }

    func start() throws {
        // DO THIS FIRST
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [])
        try audioSession.setActive(true)
        
        
        let inputNode = audioEngine.inputNode
        

        print("Input Format:")
        print(inputNode.inputFormat(forBus: 0))

        print("Output Format:")
        print(inputNode.outputFormat(forBus: 0))
        
        let format = inputNode.outputFormat(forBus: 0)

        print("Sample Rate:", format.sampleRate)
        print("Channels:", format.channelCount)

        guard format.sampleRate > 0 else {
            print("❌ Invalid sample rate")
            return
        }

        inputNode.removeTap(onBus: 0)

        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { buffer, _ in

            print("Frame Length:", buffer.frameLength)
                print("Channels:", buffer.format.sampleRate)
        }

        audioEngine.prepare()
        try audioEngine.start()

        print("✅ Audio Engine Started")
    }

    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        print("🛑 Audio Engine Stopped")
    }
    
    
    func checkMicrophonePermission() {

        let permission = AVAudioSession.sharedInstance().recordPermission

        print("Microphone Permission Status:", permission.rawValue)
    }
}
