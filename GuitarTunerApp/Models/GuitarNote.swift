//
//  GuitarNote.swift
//  GuitarTunerApp
//
//  Created by Negi on 21/06/26.
//

import Foundation
struct GuitarNote {
    let name: String
    let frequency: Double
    var period: Double { 1.0 / frequency }
    
}


extension GuitarNote {
    // Standard EADGBE tuning, low to high
    static let standardTuning: [GuitarNote] = [
        GuitarNote(name: "E2", frequency: 82.41), // Low E
        GuitarNote(name: "A2", frequency: 110.00),
        GuitarNote(name: "D3", frequency: 146.83),
        GuitarNote(name: "G3", frequency: 196.00),
        GuitarNote(name: "B3", frequency: 246.94),
        GuitarNote(name: "E4", frequency: 329.63) // High E
    ]
}
