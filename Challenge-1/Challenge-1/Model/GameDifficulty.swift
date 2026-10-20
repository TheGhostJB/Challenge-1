//
//  GameDifficulty.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 19/10/2026.
//

import Foundation

enum GameDifficulty: String, Codable, CaseIterable, Hashable, Identifiable {
    case easy
    case medium
    case hard

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .easy: "Easy"
        case .medium: "Medium"
        case .hard: "Hard"
        }
    }
}
