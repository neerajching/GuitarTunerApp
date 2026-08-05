//
//  AudioEngineManager.swift
//  GuitarTunerApp
//
//  Created by Negi on 16/06/26.
//
import Foundation
import AVFoundation

struct AudioSnapshot {
    let samples: [Float]
    let sampleRate: Double
    let rms: Float
}

final class AudioEngineManager {

    private let audioEngine = AVAudioEngine()
    private let fftWindowSize = 1024
    private var sampleAccumulator: [Float] = []

    var onSnapshot: ((AudioSnapshot) -> Void)?

    /// Current mic permission status without prompting.
    var currentPermissionStatus: AVAudioApplication.recordPermission {
        AVAudioApplication.shared.recordPermission
    }

    /// Prompts the system dialog if status is undetermined. Completion always
    /// fires on the main thread so callers can update UI state directly.
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func start() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [])
        try audioSession.setActive(true)

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        guard format.sampleRate > 0 else {
            print("❌ Invalid sample rate")
            return
        }

        inputNode.removeTap(onBus: 0)

        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { [weak self] buffer, _ in
            self?.handleBuffer(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        sampleAccumulator.removeAll()
    }

    func checkMicrophonePermission() {
        print("Microphone Permission Status:", currentPermissionStatus.rawValue)
    }

    private func handleBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }

        let count = Int(buffer.frameLength)
        let newSamples = Array(
            UnsafeBufferPointer(start: channelData[0], count: count)
        )

        sampleAccumulator.append(contentsOf: newSamples)

        while sampleAccumulator.count >= fftWindowSize {
            let window = Array(sampleAccumulator.prefix(fftWindowSize))
            sampleAccumulator.removeFirst(fftWindowSize)

            let rms = sqrt(
                window.map { $0 * $0 }.reduce(0, +) / Float(fftWindowSize)
            )

            let snap = AudioSnapshot(
                samples: window,
                sampleRate: buffer.format.sampleRate,
                rms: rms
            )

            onSnapshot?(snap)
        }
    }
}

// MARK: TAP FIRES ON A BACKGROUND AUDIO THREAD — SWIFTUI UPDATES MUST HAPPEN ON MAIN THREAD
//MARK: TAP FIRES ON A BACKGROUND AUDIO THREAD : SWIFT UI UPDATES SHOULD BE ON MAIN THREAD :: USE DISPATCH QUEUE MAIN ASYNC





/*
 
 // Step 1: Guard — floatChannelData is optional
 guard let channelData = buffer.floatChannelData else { return }
 
 
 // Step 2: Get channel 0 (the microphone)
 let channel0: UnsafeMutablePointer<Float> = channelData[0]
 
 
 // Step 3: Wrap in UnsafeBufferPointer with the correct count
 let frameCount = Int(buffer.frameLength)
 let pointer = UnsafeBufferPointer(start: channel0, count: frameCount)
 
 
 // Step 4: Copy into a safe Swift Array — now you can use it normally
 let samples: [Float] = Array(pointer)
 // samples is now a normal [Float] you can map, filter, pass around
 print(samples[0]) // First sample
 
 print(samples.count) // number of Samples
 
 */
