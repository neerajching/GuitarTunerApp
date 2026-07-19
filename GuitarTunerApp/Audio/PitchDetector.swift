//
//  PitchDetector.swift
//  GuitarTunerApp
//
//  Created by Negi on 19/07/26.
//

import Foundation

enum PeakDetector {
    /// Minimum magnitude for a bin to be considered a real signal peak
    private static let magnitudeThreshold: Float = 10.0
    /// Minimum Hz to consider — skip DC and rumble below guitar range
    private static let minHz: Double = 60.0
    /// Maximum Hz — above High E harmonic range
    private static let maxHz: Double = 1400.0
    /// Takes an FFT magnitude spectrum, returns the dominant frequency in Hz.
    /// /// Returns nil if the signal is too quiet or no clear peak exists.
    static func dominantFrequency( in magnitudes: [Float], sampleRate: Double, rms: Float ) -> Double? { // Gate 1 — silence check
        guard rms > 0.02 else { return nil
        }
        let binWidth = sampleRate / Double(magnitudes.count * 2)
        // Convert Hz limits to bin indices
        let minBin = max(2, Int(minHz / binWidth))
        let maxBin = min(magnitudes.count - 2, Int(maxHz / binWidth)) // Find peak bin within the valid guitar frequency range
        guard minBin < maxBin else { return nil }
        var peakBin = minBin
        var peakMag = magnitudes[minBin]
        
        for bin in minBin...maxBin {
            if magnitudes[bin] > peakMag {
                peakMag = magnitudes[bin]
                peakBin = bin
            }
        }
        // Gate 2 — magnitude check (not just noise in a quiet spectrum)
        guard peakMag > magnitudeThreshold else { return nil }
        // Parabolic interpolation for sub-bin precision
        let left = Float(peakBin > 0 ? magnitudes[peakBin - 1] : 0)
        let center = peakMag
        let right = Float(peakBin < magnitudes.count - 1 ? magnitudes[peakBin + 1] : 0)
        let denominator = left - 2 * center + right
        let offset: Double
        
        if abs(denominator) > 0.0001 {
            offset = 0.5 * Double(left - right) / Double(denominator)
        } else { offset = 0.0
            // flat peak, no interpolation needed
        }
        return (Double(peakBin) + offset) * binWidth
    }
}
