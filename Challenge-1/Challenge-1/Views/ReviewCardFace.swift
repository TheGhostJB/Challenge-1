//
//  ReviewCardFace.swift
//  Challenge-1
//
//  Created by Giuseppe Di Donna on 21/10/2026.
//

import Foundation
import SwiftUI

struct ReviewCardFace: View {
    let question: String
    let answer: String
    let ownerName: String
    let difficulty: GameDifficulty
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        let theme = difficulty.theme

        VStack(spacing: 0) {
            Text(question)
                .font(.system(size: width * 0.075, weight: .heavy))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .padding(.top, height * 0.12)

            Spacer(minLength: 16)

            Text("\(ownerName)'s answer:")
                .font(.subheadline)
                .opacity(0.8)
                .padding(.bottom, 10)

            Text(answer)
                .font(.system(size: width * 0.09, weight: .heavy))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(5)

            Spacer(minLength: 16)

            Text("uGuess")
                .font(.footnote.weight(.bold))
                .opacity(0.4)
        }
        .foregroundStyle(theme.text)
        .padding(.horizontal, width * 0.1)
        .padding(.bottom, 20)
        .frame(width: width, height: height)
        .background(theme.gradient, in: .rect(cornerRadius: 36))
        .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
    }
}

#Preview {
    ReviewCardFace(
        question: "AAAAAA",
        answer: "BBBBB",
        ownerName: "Diego",
        difficulty: .easy,
        width: 280,
        height: 378
    )
    .padding(40)
    .preferredColorScheme(.light)
}
