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
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(question)
                    .font(.title2.bold().lowercaseSmallCaps())
                    .multilineTextAlignment(.center)
                    .padding()
                    

                Text(answer)
                    .font(.title3)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, width * 0.13)
            .padding(.vertical, 28)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .frame(width: width, height: height)
        .background(
            Color(hex: 0xF3F2F7),
            in: .rect(cornerRadius: 36)
        )
        .clipShape(.rect(cornerRadius: 36))
        .shadow(
            color: .black.opacity(0.06),
            radius: 2,
            y: 1
        )
    }
}

#Preview {
    ReviewCardFace(
        question: "AAAAAA",
        answer: "BBBBB",
        width: 280,
        height: 378
    )
    .padding(40)
    .preferredColorScheme(.light)
}
