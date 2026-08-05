//
//  TunerViewModel.swift
//  GuitarTunerApp
//
//  Created by Negi on 16/06/26.
//
import Foundation
import Observation
import AVFoundation

enum MicPermissionState {
    case undetermined
    case granted
    case denied
}

@Observable
final class TunerViewModel {

    private let audioManager = AudioEngineManager()
    private let fft = FFTProcessor(fftSize: 1024)

    var rms: Float = 0
    var isListening = false
    var detectedFrequency: Double?
    var permissionState: MicPermissionState = .undetermined

    // Light smoothing so the note/frequency glide instead of flickering
    // frame-to-frame. Median-of-N kills single-frame octave/harmonic
    // outliers; the EMA on top of that gives the "buttery" motion.
    private var recentFrequencies: [Double] = []
    private let historyLength = 5
    private let emaFactor = 0.35
    private var smoothedFrequency: Double?

    init() {
        audioManager.onSnapshot = { [weak self] snap in
            guard let self else { return }

            let spectrum = self.fft.magnitudes(of: snap.samples)
            let rawFrequency = PeakDetector.dominantFrequency(
                in: spectrum,
                sampleRate: snap.sampleRate,
                rms: snap.rms
            )

            let smoothed = self.smooth(rawFrequency)
            
            let rawStr = rawFrequency.map { String(format: "%.1f", $0) } ?? "nil"
            let smoothStr = smoothed.map { String(format: "%.1f", $0) } ?? "nil"
            print("🎵 raw: \(rawStr) smoothed: \(smoothStr)")
            
            DispatchQueue.main.async {
                self.rms = snap.rms
                self.detectedFrequency = smoothed
            }
        }
    }

    /// Call this on view appear instead of requestPermission()+startListening()
    /// separately — it sequences them correctly so we never start the engine
    /// before the system permission dialog has actually resolved.
    func prepareAudio() {
        switch audioManager.currentPermissionStatus {
        case .granted:
            permissionState = .granted
            startListening()
        case .denied:
            permissionState = .denied
        case .undetermined:
            audioManager.requestMicrophonePermission { [weak self] granted in
                guard let self else { return }
                self.permissionState = granted ? .granted : .denied
                if granted {
                    self.startListening()
                }
            }
        @unknown default:
            permissionState = .denied
        }
    }

    func startListening() {
        do {
            try audioManager.start()
            isListening = true
        } catch {
            print("❌ Failed to start audio engine:", error.localizedDescription)
            isListening = false
        }
    }

    func stopListening() {
        audioManager.stop()
        isListening = false
        recentFrequencies.removeAll()
        smoothedFrequency = nil
    }

    /// Median-of-N followed by an exponential moving average.
    /// Resets cleanly to nil on silence so the note doesn't "hang" between notes.

    private func smooth(_ frequency: Double?) -> Double? {

        // Treat nil, negative, or out-of-range as silence — hard reset
        guard let frequency,
              frequency > 75,
              frequency < 1400 else {

            recentFrequencies.removeAll()
            smoothedFrequency = nil
            return nil
        }

        // If the new reading is more than 40% from the current smooth value,
        // it's likely a harmonic jump or noise spike — hard reset to the new value.
        if let prev = smoothedFrequency,
           abs(frequency - prev) / prev > 0.40 {

            recentFrequencies.removeAll()
            smoothedFrequency = frequency
            return smoothedFrequency
        }

        recentFrequencies.append(frequency)

        if recentFrequencies.count > historyLength {
            recentFrequencies.removeFirst()
        }

        let sorted = recentFrequencies.sorted()
        let median = sorted[sorted.count / 2]

        if let previous = smoothedFrequency {
            smoothedFrequency = previous + (median - previous) * emaFactor
        } else {
            smoothedFrequency = median
        }

        return smoothedFrequency
    }
}
