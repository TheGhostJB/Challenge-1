//
//  ReviewDeckView.swift
//  Challenge-1
//
//  Created by Giuseppe Di Donna on 21/10/2026.
//

import Foundation

import SwiftUI

struct ReviewDeckView: View {
    @ObservedObject var deck: CardDeckState<ReviewItem>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width * 0.72, 340)
            let height = width * 1.35

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 24)

                    CardDeck(
                        deck: deck,
                        cardWidth: width,
                        cardHeight: height,
                        flipAngle: 0,
                        isAnswering: false,
                        onTap: {},
                        cardAccessibilityLabel: {
                            "\($0.question)\n\($0.answer)"
                        }
                    ) { item in
                        ReviewCardFace(
                            question: item.question,
                            answer: item.answer,
                            width: width,
                            height: height
                        )
                    }

                    Text("Card \(deck.topCardIndex + 1) of \(deck.cards.count)")
                        .font(.subheadline)
                        .foregroundStyle(.black)

                    LobbyPillButton(
                        title: "Next",
                        action: { nextCard(cardWidth: width) },
                        font: .title3
                    )
                    .disabled(deck.isCycling || deck.cards.count < 2)

                    Spacer(minLength: 24)
                }
                .frame(minHeight: geometry.size.height)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private func nextCard(cardWidth: CGFloat) {
        deck.cycleCard(
            direction: -1,
            cardWidth: cardWidth,
            reduceMotion: reduceMotion
        )
    }
}
