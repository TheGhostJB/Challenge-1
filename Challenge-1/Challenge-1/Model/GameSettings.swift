//
//  GameSettings.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 19/10/2026.
//

import Foundation

struct GameSettings: Codable, Hashable {
    var difficulty: GameDifficulty
    var rounds: Int

    static let standard = GameSettings(difficulty: .easy, rounds: 3)
}
