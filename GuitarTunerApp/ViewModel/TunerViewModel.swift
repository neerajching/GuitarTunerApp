//
//  TunerViewModel.swift
//  GuitarTunerApp
//
//  Created by Negi on 16/06/26.
//
import Foundation
import Observation


//MARK: runs FFT on each snapshot → prints top 5 bins by magnitude

@Observable
final class TunerViewModel {
    
    private let audioManager = AudioEngineManager()
    
    var rms: Float = 0
    
    //    var sampleRate: Double = 0
    //    var sampleCount: Int = 0
    
    var isListening = false
    var detectedFrequency: Double?
    
    private let fft = FFTProcessor(fftSize: 1024)
    
//    init() {
//        audioManager.onSnapshot = { [weak self] snap in
//            guard let self else {
//                return
//            }
//            print("Sample count:", snap.samples.count)
//            let spectrum = self.fft.magnitudes(of: snap.samples)
//            
//            print("Spectrum count:", spectrum.count)
//            
//            
//            
//            // EXecute in main thread
//            //NOTE: since we are in the audio thread. the following code should be axecuted on the main thread
//            
//            //installTap -> Audio Thread -> handleBuffer() -> onSnapshot()  -> this closure lives here
//            
//            DispatchQueue.main.async {
//                self.rms = snap.rms
//                
//                
//                // print top 5 bins by magnitude
//                
//                let top5 = spectrum.enumerated()
//                    .sorted { $0.element > $1.element }
//                    .prefix(5)
//                print("Top5 count:", top5.count)
//                
//                let binWidth = snap.sampleRate / Double(spectrum.count * 2)
//                
//                
//                for (bin, mag) in top5 {
//                    let hz = Double(bin) * binWidth
//                    
//                    print(
//                        "bin \(bin) → \(Int(hz)) Hz — magnitude \(Int(mag))"
//                    )
//                }
//                
//                print("---")
//            }
//        }
//    }
    
    
    init() { audioManager.onSnapshot = { [weak self] snap in
        guard let self else { return }
        let spectrum = self.fft.magnitudes(of: snap.samples)
        // Detect dominant frequency from FFT spectrum
        let freq = PeakDetector.dominantFrequency( in: spectrum, sampleRate: snap.sampleRate, rms: snap.rms )
            DispatchQueue.main.async {
                self.rms = snap.rms
                self.detectedFrequency = freq
                // Keep this for now so you can validate the output
                if let freq {
                    print("🎵 \(String(format: "%.1f", freq)) Hz")
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
