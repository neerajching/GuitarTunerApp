//
//  MainTab.swift
//  GuitarTunerApp
//
//  Created by Negi on 04/08/26.
//

import Foundation


enum MainTab: String, CaseIterable, Identifiable {
    case home
    case tuner
    case learn
    case practice
    case profile
    
    var id: Self { self }
    
    
    var title: String {
        switch self {
        
        case .home:
            return "Home"
        case .tuner:
            return "Tuner"

        case .learn:
            return "Learn"

        case .practice:
            return "Practice"

        case .profile:
            return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        
        case .home:
            return "house"
        case .tuner:
            return "waveform"

        case .learn:
            return "book.closed"

        case .practice:
            return "music.note.list"

        case .profile:
            return "person.crop.circle"
        }
    }
    
    var selectedSystemImage: String {
        switch self {
        case .home:
            "house.fill"

        case .tuner:
            "waveform"

        case .learn:
            "book.closed.fill"

        case .practice:
            "music.note.list"

        case .profile:
            "person.crop.circle.fill"
        }
    }
    
    func icon(selected: Bool) -> String {
            selected ? selectedSystemImage : systemImage
        }
    
}
