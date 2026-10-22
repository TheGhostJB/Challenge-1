//
//  CardDeck.swift
//  Challenge-1
//
//  Created by Giuseppe Di Donna on 21/10/2026.
//

import Foundation
import SwiftUI

// MARK: - The deck
    
struct CardDeck<Item: Identifiable, Content: View>: View {
        @ObservedObject var deck: CardDeckState<Item>
        let cardWidth: CGFloat
        let cardHeight: CGFloat
        let flipAngle: Double
        let isAnswering: Bool
        let onTap: () -> Void
        let cardAccessibilityLabel: (Item) -> String
        let cardContent: (Item) -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var sizeRatio: CGFloat { cardWidth / 180 }
    private var progress: CGFloat {
        reduceMotion ? 0 : min(abs(deck.dragOffset) / (150 * sizeRatio), 1)
    }
    private var signedProgress: CGFloat { (deck.dragOffset >= 0 ? 1 : -1) * progress }

    var body: some View {
        ZStack {
            ForEach(Array(deck.cards.enumerated()), id: \.element.id) { index, card in
                let depth = (index - deck.topCardIndex + deck.cards.count) % deck.cards.count

                cardContent(card)
                    .offset(
                        x: depth == 0 ? (reduceMotion ? 0 : deck.dragOffset) : CGFloat(depth) * 10 * sizeRatio,
                        y: -CGFloat(depth) * 4 * sizeRatio
                    )
                    .zIndex(Double(deck.cards.count - depth))
                    .rotationEffect(
                        .degrees(depth == 0 ? 0 : Double(depth) * 3 - Double(progress) * 3),
                        anchor: .bottom
                    )
                    .scaleEffect(scale(for: depth))
                    .offset(x: -CGFloat(depth) * 3 * sizeRatio)
                    .rotation3DEffect(
                        .degrees(!reduceMotion && depth <= 1 ? 10 * Double(signedProgress) : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .rotation3DEffect(.degrees(depth == 0 ? flipAngle : 0), axis: (x: 0, y: 1, z: 0))
                    .opacity(opacity(for: depth))
                    .accessibilityHidden(depth != 0)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .contentShape(.rect)
        .onTapGesture(perform: onTap)
        .simultaneousGesture(
            DragGesture(minimumDistance: 10)
                .onChanged { deck.dragChanged($0) }
                .onEnded { deck.dragEnded($0, cardWidth: cardWidth, reduceMotion: reduceMotion) }
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(deck.currentCard.map(cardAccessibilityLabel) ?? "")
        .accessibilityValue("Card \(deck.topCardIndex + 1) of \(deck.cards.count)")
        .frame(maxWidth: .infinity)
    }

    private func scale(for depth: Int) -> CGFloat {
        depth == 0 ? 1 : 1 - CGFloat(depth) * 0.06 + (depth == 1 ? progress * 0.06 : 0)
    }

    private func opacity(for depth: Int) -> Double {
        if depth == 0 { return 1 }
        if isAnswering || depth > 3 { return 0 }
        return 1
    }
}
