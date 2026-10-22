//
//  QuestionDeck.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 20/10/2026.
//

import SwiftUI

// MARK: - Card faces

struct QuestionCardFace: View {
    let question: String
    let difficulty: GameDifficulty
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        let theme = difficulty.theme

        Text(question)
            .font(.system(size: width * 0.095, weight: .heavy))
            .foregroundStyle(theme.text)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, width * 0.12)
            .frame(width: width, height: height)
            .background(theme.gradient, in: .rect(cornerRadius: 36))
            .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
    }
}

struct AnswerCard: View {
    let question: String
    let difficulty: GameDifficulty
    @Binding var answer: String
    let isFocused: FocusState<Bool>.Binding
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

            Text("Your answer")
                .font(.subheadline.weight(.semibold))
                .opacity(0.8)
                .padding(.bottom, 10)

            HStack(spacing: 8) {
                TextField("Type here", text: $answer, axis: .vertical)
                    .lineLimit(1...3)
                    .focused(isFocused)
                    .tint(theme.text)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") { isFocused.wrappedValue = false }
                        }
                    }

                if !answer.isEmpty {
                    Button("Clear answer", systemImage: "xmark.circle.fill") {
                        answer = ""
                        isFocused.wrappedValue = true
                    }
                    .labelStyle(.iconOnly)
                    .opacity(0.6)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .cardField(tint: theme.text)

            Spacer(minLength: 24)
        }
        .foregroundStyle(theme.text)
        .padding(.horizontal, width * 0.1)
        .frame(width: width, height: height)
        .background(theme.gradient, in: .rect(cornerRadius: 36))
        .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
    }
}

// MARK: - The deck

struct QuestionCardDeck: View {
    @ObservedObject var deck: QuestionDeckState
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let flipAngle: Double
    let isAnswering: Bool
    let onTap: () -> Void

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

                QuestionCardFace(question: card.text, difficulty: card.difficulty, width: cardWidth, height: cardHeight)
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
        .accessibilityLabel(deck.currentCard?.text ?? "")
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
