//
//  ZeroCrossingDetector.swift
//  GuitarTunerApp
//
//  Created by Negi on 21/06/26.
//

import Foundation

enum ZeroCrossingPitchDetector {
    private static let silenceThreshold: Float = 0.01
    
    static func detectFrequency(
        samples: [Float],
        sampleRate: Double,
        rms: Float
    ) -> Double? {
        guard samples.count > 2 else {
            return nil
        }

        guard rms > silenceThreshold else {
            return nil
        }
        
        var crossings = 0
        
        for i in 1..<samples.count {
            let prev = samples[i - 1]
            let curr = samples[i]
            
            if (prev >= 0 && curr < 0) ||
                (prev < 0 && curr >= 0) {
                crossings += 1
            }
        }
        
        let cycles = Double(crossings) / 2.0
        
        let duration = Double(samples.count) / sampleRate
        
        let frequency = cycles / duration
        
        return frequency
        
    }
}
