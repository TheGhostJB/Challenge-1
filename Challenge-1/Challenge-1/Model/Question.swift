//
//  Question.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 19/10/2026.
//

import Foundation

struct Question: Identifiable, Hashable {
    let id: Int
    let text: String
    let difficulty: GameDifficulty
}

enum QuestionBank {
    static let all: [Question] = [
        // Easy: 1 to 10
        Question(id: 1, text: "What is their favorite food?", difficulty: .easy),
        Question(id: 2, text: "What is their dream vacation spot?", difficulty: .easy),
        Question(id: 3, text: "What is their favorite movie?", difficulty: .easy),
        Question(id: 4, text: "What is their favorite song right now?", difficulty: .easy),
        Question(id: 5, text: "Are they a morning person or a night owl?", difficulty: .easy),
        Question(id: 6, text: "What is their favorite season of the year?", difficulty: .easy),
        Question(id: 7, text: "What is their go-to comfort food?", difficulty: .easy),
        Question(id: 8, text: "What is their favorite app on their phone?", difficulty: .easy),
        Question(id: 9, text: "Do they prefer cats or dogs?", difficulty: .easy),
        Question(id: 10, text: "What superpower would they pick?", difficulty: .easy),

        // Medium: 100 to 109
        Question(id: 100, text: "What is the most embarrassing thing they have done?", difficulty: .medium),
        Question(id: 101, text: "What is their biggest fear?", difficulty: .medium),
        Question(id: 102, text: "What would they do with a million dollars?", difficulty: .medium),
        Question(id: 103, text: "What is a skill they wish they had?", difficulty: .medium),
        Question(id: 104, text: "What is the best trip they have ever taken?", difficulty: .medium),
        Question(id: 105, text: "What is a habit they are trying to change?", difficulty: .medium),
        Question(id: 106, text: "Who is a person they really look up to?", difficulty: .medium),
        Question(id: 107, text: "What is the best gift they have ever received?", difficulty: .medium),
        Question(id: 108, text: "What is something they are proud of but rarely talk about?", difficulty: .medium),
        Question(id: 109, text: "What would their perfect day look like?", difficulty: .medium),

        // Hard: 200 to 209
        Question(id: 200, text: "What is a childhood memory they treasure?", difficulty: .hard),
        Question(id: 201, text: "What do they want to be doing in ten years?", difficulty: .hard),
        Question(id: 202, text: "What is the hardest decision they have made?", difficulty: .hard),
        Question(id: 203, text: "What is something they wish they had done differently?", difficulty: .hard),
        Question(id: 204, text: "What is a dream they have never told many people?", difficulty: .hard),
        Question(id: 205, text: "What moment changed how they see the world?", difficulty: .hard),
        Question(id: 206, text: "What do they value most in a friendship?", difficulty: .hard),
        Question(id: 207, text: "What is the best advice they have ever been given?", difficulty: .hard),
        Question(id: 208, text: "What is something they are still learning to forgive?", difficulty: .hard),
        Question(id: 209, text: "What would they tell their younger self?", difficulty: .hard)
    ]

    static func questions(for difficulty: GameDifficulty) -> [Question] {
        all.filter { $0.difficulty == difficulty }
    }

    static func question(withID id: Int) -> Question? {
        all.first { $0.id == id }
    }
}
