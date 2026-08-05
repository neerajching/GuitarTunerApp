//
//  Pitch math.swift
//  GuitarTunerApp
//
//  Created by Negi on 19/07/26.
//

import Foundation

struct GuitarString: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let frequency: Double // Hz, standard tuning
}

enum StandardTuning {
    /// Low E to high E
    static let strings: [GuitarString] = [
        GuitarString(name: "E", frequency: 82.41),
        GuitarString(name: "A", frequency: 110.00),
        GuitarString(name: "D", frequency: 146.83),
        GuitarString(name: "G", frequency: 196.00),
        GuitarString(name: "B", frequency: 246.94),
        GuitarString(name: "E", frequency: 329.63)
    ]
}

enum TuningStatus: Equatable {
    case silent
    case tooLow
    case inTune
    case tooHigh
}

enum PitchMath {

    static let noteNames = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]

    /// Nearest chromatic note name for a frequency (A4 = 440 Hz reference).
    static func nearestNote(for frequency: Double) -> (name: String, octave: Int) {
        guard frequency > 0 else { return ("–", 0) }
        let midi = 69.0 + 12.0 * log2(frequency / 440.0)
        let rounded = midi.rounded()
        var index = Int(rounded) % 12
        if index < 0 { index += 12 }
        let octave = Int(rounded) / 12 - 1
        return (noteNames[index], octave)
    }

    /// Cents offset of `frequency` relative to some target frequency.
    /// Positive = sharp (too high), negative = flat (too low).
    static func cents(of frequency: Double, relativeTo target: Double) -> Double {
        guard frequency > 0, target > 0 else { return 0 }
        return 1200.0 * log2(frequency / target)
    }

    static func status(forCents cents: Double, tolerance: Double = 5.0) -> TuningStatus {
        if cents < -tolerance { return .tooLow }
        if cents > tolerance { return .tooHigh }
        return .inTune
    }

    /// Index of the standard-tuning string closest to a detected frequency.
    /// Distance measured in cents so it's musically meaningful (not raw Hz).
    static func nearestStringIndex(to frequency: Double, in strings: [GuitarString] = StandardTuning.strings) -> Int? {
        guard frequency > 0 else { return nil }
        var bestIndex: Int?
        var bestDistance = Double.greatestFiniteMagnitude
        for (i, string) in strings.enumerated() {
            let distance = abs(cents(of: frequency, relativeTo: string.frequency))
            if distance < bestDistance {
                bestDistance = distance
                bestIndex = i
            }
        }
        return bestIndex
    }
}
