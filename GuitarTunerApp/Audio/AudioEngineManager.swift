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
            bufferSize: 1024,
            format: format
        ) { [weak self ] buffer, _ in
            
            
            // \MARK: self.snapshot returns AudioSnapshot and assign it to snap.
            guard let snap = Self.snapshot(from: buffer) else{
                return
            }
            
            
            
            // MARK: assign self.onSnapshot block on snap
            self?.onSnapshot?(snap)
            
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
