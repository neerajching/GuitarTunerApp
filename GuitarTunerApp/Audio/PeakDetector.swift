//
//  PitchDetector.swift
//  GuitarTunerApp
//
//  Created by Negi on 19/07/26.
//

import Foundation

enum PeakDetector {

    private static let rmsThreshold: Float = 0.02
    // Back to original — 0.005 was below the noise floor

    private static let magnitudeThreshold: Float = 200.0
    // Raised — weak bins are usually noise

    private static let minHz: Double = 75.0
    // Raised — skip the 70.3 Hz artefact bin

    private static let maxHz: Double = 1400.0

    /// These exact Hz values are device noise artefacts on your phone.
    /// Reject any reading within 3 Hz of them.
    private static let artefactHz: [Double] = [
        70.3125,
        117.1875,
        140.625
    ]

    static func dominantFrequency(
        in magnitudes: [Float],
        sampleRate: Double,
        rms: Float
    ) -> Double? {

        guard rms > rmsThreshold else {
            return nil
        }

        let binWidth = sampleRate / Double(magnitudes.count * 2)

        let minBin = max(2, Int(minHz / binWidth))
        let maxBin = min(
            magnitudes.count - 2,
            Int(maxHz / binWidth)
        )

        guard minBin < maxBin else {
            return nil
        }

        // Find peak bin
        var peakBin = minBin
        var peakMag = magnitudes[minBin]

        for bin in minBin...maxBin {
            if magnitudes[bin] > peakMag {
                peakMag = magnitudes[bin]
                peakBin = bin
            }
        }

        guard peakMag > magnitudeThreshold else {
            return nil
        }

        // Parabolic interpolation — clamped offset
        let left = magnitudes[peakBin - 1]
        let center = peakMag
        let right = magnitudes[peakBin + 1]

        let denom = left - 2 * center + right

        var offset: Double = 0

        if abs(denom) > 1.0 {
            offset = 0.5 * Double(left - right) / Double(denom)
            offset = max(-0.5, min(0.5, offset))
        }

        let rawFreq = (Double(peakBin) + offset) * binWidth

        guard rawFreq > 0 else {
            return nil
        }

        // Reject known device artefact frequencies
        for artefact in artefactHz {
            if abs(rawFreq - artefact) < 3.0 {
                return nil
            }
        }

        // Harmonic check — if half-frequency has ≥20% energy,
        // use it instead.
        let halfFreq = rawFreq / 2.0

        if halfFreq >= minHz {

            let halfBin = Int((halfFreq / binWidth).rounded())

            if halfBin >= 0 && halfBin < magnitudes.count {

                if magnitudes[halfBin] > peakMag * 0.2 {
                    return halfFreq
                }
            }
        }

        return rawFreq
    }
}
