//
//  PitchDetector.swift
//  GuitarTunerApp
//
//  Created by Negi on 15/09/26.
//

import Foundation

enum PitchDetector {

    // MARK: - Detection Range

    /// Slightly wider than the standard guitar range.
    private static let minFrequency: Double = 70.0
    private static let maxFrequency: Double = 400.0

    /// Minimum signal level required for pitch detection.
    private static let rmsThreshold: Float = 0.015

    /// Minimum normalized autocorrelation confidence.
    private static let confidenceThreshold: Double = 0.60

    // MARK: - Public API

    static func detect(
        samples: [Float],
        sampleRate: Double,
        rms: Float
    ) -> Double? {

        guard rms >= rmsThreshold else {
            return nil
        }

        guard sampleRate > 0 else {
            return nil
        }

        guard samples.count >= 2 else {
            return nil
        }

        let samples = removeDCOffset(from: samples)

        let minLag = Int(sampleRate / maxFrequency)
        let maxLag = Int(sampleRate / minFrequency)

        guard minLag > 0,
              maxLag < samples.count else {
            return nil
        }

        let correlations = autocorrelation(
            samples: samples,
            minLag: minLag,
            maxLag: maxLag
        )

        guard let peakLag = findBestPeak(
            in: correlations,
            minLag: minLag,
            maxLag: maxLag
        ) else {
            return nil
        }

        let confidence = correlations[peakLag]

        guard confidence >= confidenceThreshold else {
            return nil
        }

        let refinedLag = interpolatePeak(
            correlations,
            at: peakLag
        )

        guard refinedLag > 0 else {
            return nil
        }

        let frequency = sampleRate / refinedLag

        guard frequency >= minFrequency,
              frequency <= maxFrequency else {
            return nil
        }

        return frequency
    }

    // MARK: - DC Removal

    private static func removeDCOffset(
        from samples: [Float]
    ) -> [Float] {

        let mean = samples.reduce(0, +) / Float(samples.count)

        return samples.map {
            $0 - mean
        }
    }

    // MARK: - Autocorrelation

    private static func autocorrelation(
        samples: [Float],
        minLag: Int,
        maxLag: Int
    ) -> [Double] {

        var result = [Double](
            repeating: 0,
            count: maxLag + 1
        )

        for lag in minLag...maxLag {

            let count = samples.count - lag

            var sum: Double = 0
            var energyA: Double = 0
            var energyB: Double = 0

            for index in 0..<count {

                let a = Double(samples[index])
                let b = Double(samples[index + lag])

                sum += a * b
                energyA += a * a
                energyB += b * b
            }

            let denominator = sqrt(
                energyA * energyB
            )

            guard denominator > 0 else {
                continue
            }

            result[lag] = sum / denominator
        }

        return result
    }

    // MARK: - Peak Detection

    private static func findBestPeak(
        in correlations: [Double],
        minLag: Int,
        maxLag: Int
    ) -> Int? {

        guard maxLag > minLag + 2 else {
            return nil
        }

        var bestLag: Int?
        var bestCorrelation = -Double.infinity

        for lag in (minLag + 1)..<maxLag {

            let previous = correlations[lag - 1]
            let current = correlations[lag]
            let next = correlations[lag + 1]

            // We only want an actual local maximum.
            guard current >= previous,
                  current >= next else {
                continue
            }

            if current > bestCorrelation {
                bestCorrelation = current
                bestLag = lag
            }
        }

        return bestLag
    }

    // MARK: - Sub-sample Peak Refinement

    private static func interpolatePeak(
        _ values: [Double],
        at index: Int
    ) -> Double {

        guard index > 0,
              index < values.count - 1 else {
            return Double(index)
        }

        let left = values[index - 1]
        let center = values[index]
        let right = values[index + 1]

        let denominator =
            left - (2.0 * center) + right

        guard abs(denominator) > 0.000001 else {
            return Double(index)
        }

        let offset =
            0.5 * (left - right) / denominator

        return Double(index) + offset
    }
}
