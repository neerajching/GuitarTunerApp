//
//  AudioEngineManager.swift
//  GuitarTunerApp
//
//  Created by Negi on 16/06/26.
//
import Foundation
import AVFoundation

// MARK: -  chunks 
struct AudioSnapshot {
    let samples: [Float]
    let sampleRate: Double
    let rms: Float
}

// MARK: - captures mic → accumulates samples → fires clean 1024-sample

final class AudioEngineManager {

    private let audioEngine = AVAudioEngine()
    
//    private let fftWindowSize = 1024
    
    private let fftWindowSize = 1024
    private var sampleAccumulator: [Float] = [] // NEW
   
    var onSnapshot: ((AudioSnapshot) -> Void)?
    
    func requestMicrophonePermission() {
        AVAudioApplication.requestRecordPermission { granted in
            print("🎤 Permission granted: \(granted)")
        }
    }

    func start() throws {

        // steps for micrpphone access related issues
                
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [])
        try audioSession.setActive(true)
        
        
        //MARK: real thing from here ....
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
            bufferSize: 1024, //iOS may deliver more
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
        
        print("🛑 Audio Engine Stopped")
    }
    
    func checkMicrophonePermission() {

        let permission = AVAudioSession.sharedInstance().recordPermission

        print("Microphone Permission Status:", permission.rawValue)
    }
    
    
    private static func snapshot(from buffer: AVAudioPCMBuffer) -> AudioSnapshot? {
        
        
        //MARK: channel data is array of channels
        guard let channelData = buffer.floatChannelData else {
            return nil
        }
        
        
        let count = Int(buffer.frameLength)
        
        
        //MARK: microphone is mono so only one channel (0)
        
        let samples = Array(UnsafeBufferPointer(
            start: channelData[0],
            count: count)
        )
        
        let rms = sqrt(
            samples.map{ $0 * $0 }
                .reduce(0, +) / Float(count)
            
        )
        
        return AudioSnapshot(samples: samples,
                             sampleRate: buffer.format.sampleRate,
                             rms: rms)
        
    }
    
    private func handleBuffer(_ buffer: AVAudioPCMBuffer) {

        guard let channelData = buffer.floatChannelData else {
            return
        }

        let count = Int(buffer.frameLength)

        let newSamples = Array(
            UnsafeBufferPointer(
                start: channelData[0],
                count: count
            )
        )

        // Append incoming samples to the accumulator
        sampleAccumulator.append(contentsOf: newSamples)

        // Fire a snapshot every time we have ≥ 1024 samples
        while sampleAccumulator.count >= fftWindowSize {

            let window = Array(
                sampleAccumulator.prefix(fftWindowSize)
            )

            sampleAccumulator.removeFirst(fftWindowSize)

            let rms = sqrt(
                window.map { $0 * $0 }
                    .reduce(0, +) / Float(fftWindowSize)
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
