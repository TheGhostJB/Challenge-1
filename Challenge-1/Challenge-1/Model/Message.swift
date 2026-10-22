//
//  Message.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 19/10/2026.
//

import Foundation

struct AnswerEntry: Codable, Equatable {
    let questionID: Int
    let answer: String
}

enum Message: Codable, Equatable {
    case settings(GameSettings)
    case ready(Bool)
    case name(String)
    case avatar(Int)
    case start
    case results([AnswerEntry])
    case endGame
}
