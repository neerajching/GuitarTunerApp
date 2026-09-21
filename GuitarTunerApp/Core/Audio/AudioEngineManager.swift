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

    private let analysisWindow = 4096
    private let hopSize = 2048

    private var sampleAccumulator: [Float] = []

    // MARK: - Queues

    /// Receives microphone buffers and builds analysis windows.
    private let captureQueue = DispatchQueue(
        label: "com.guitarlab.audio-capture",
        qos: .userInitiated
    )

    /// Runs the expensive pitch detection.
    private let analysisQueue = DispatchQueue(
        label: "com.guitarlab.pitch-analysis",
        qos: .userInitiated
    )

    // MARK: - Latest-Wins State

    private let stateLock = NSLock()

    /// The newest snapshot waiting to be analyzed.
    /// There can only ever be ONE pending snapshot.
    private var latestSnapshot: AudioSnapshot?

    /// Whether the detector is currently processing a snapshot.
    private var isAnalyzing = false

    // MARK: - Output

    var onSnapshot: ((AudioSnapshot) -> Void)?

    // MARK: - Permission

    var currentPermissionStatus: AVAudioApplication.recordPermission {
        AVAudioApplication.shared.recordPermission
    }

    func requestMicrophonePermission(
        completion: @escaping (Bool) -> Void
    ) {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - Start

    func start() throws {

        let audioSession = AVAudioSession.sharedInstance()

        try audioSession.setCategory(
            .record,
            mode: .measurement,
            options: []
        )

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

            guard let self else { return }

            // Do not perform work directly on the audio thread.
            self.captureQueue.async {
                self.handleBuffer(buffer)
            }
        }

        audioEngine.prepare()

        try audioEngine.start()

        print("🎙️ Audio engine started")
        print("Sample rate:", format.sampleRate)
    }

    // MARK: - Stop

    func stop() {

        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()

        captureQueue.async { [weak self] in
            self?.sampleAccumulator.removeAll()
        }

        stateLock.lock()
        latestSnapshot = nil
        isAnalyzing = false
        stateLock.unlock()

        print("🛑 Audio engine stopped")
    }

    // MARK: - Buffer Handling

    private func handleBuffer(
        _ buffer: AVAudioPCMBuffer
    ) {

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

        sampleAccumulator.append(contentsOf: newSamples)

        while sampleAccumulator.count >= analysisWindow {

            let window = Array(
                sampleAccumulator.prefix(analysisWindow)
            )

            sampleAccumulator.removeFirst(hopSize)

            let rms = calculateRMS(window)

            let snapshot = AudioSnapshot(
                samples: window,
                sampleRate: buffer.format.sampleRate,
                rms: rms
            )

            submitLatestSnapshot(snapshot)
        }
    }

    // MARK: - Latest Wins

    private func submitLatestSnapshot(
        _ snapshot: AudioSnapshot
    ) {

        stateLock.lock()

        // Always replace whatever was waiting.
        latestSnapshot = snapshot

        // Someone is already analyzing.
        // We don't start another job.
        if isAnalyzing {
            stateLock.unlock()
            return
        }

        // Start exactly one analysis worker.
        isAnalyzing = true

        stateLock.unlock()

        analysisQueue.async { [weak self] in
            self?.processLatestSnapshots()
        }
    }

    // MARK: - Analysis Worker

    private func processLatestSnapshots() {

        while true {

            stateLock.lock()

            // Take the newest available snapshot.
            guard let snapshot = latestSnapshot else {

                isAnalyzing = false

                stateLock.unlock()

                return
            }

            // Remove it from pending.
            latestSnapshot = nil

            stateLock.unlock()

            // ----------------------------------------
            // EXPENSIVE WORK HAPPENS HERE
            // ----------------------------------------

            onSnapshot?(snapshot)

            // ----------------------------------------
            // When detection finishes:
            //
            // If another snapshot arrived while we
            // were calculating, the loop immediately
            // takes ONLY the newest one.
            // ----------------------------------------
        }
    }

    // MARK: - RMS

    private func calculateRMS(
        _ samples: [Float]
    ) -> Float {

        var sum: Float = 0

        for sample in samples {
            sum += sample * sample
        }

        return sqrt(
            sum / Float(samples.count)
        )
    }

    // MARK: - Permission

    func checkMicrophonePermission() {

        print(
            "Microphone Permission Status:",
            currentPermissionStatus.rawValue
        )
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
