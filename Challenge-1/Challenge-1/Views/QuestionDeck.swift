//
//  QuestionDeck.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 20/10/2026.
//

import SwiftUI
import Combine

// MARK: - Deck state

@MainActor
final class QuestionDeckState: ObservableObject {
    @Published private(set) var cards: [Question] = []
    @Published private(set) var topCardIndex = 0
    @Published private(set) var dragOffset: CGFloat = 0
    @Published private(set) var isCycling = false

    var currentCard: Question? {
        cards.isEmpty ? nil : cards[topCardIndex]
    }

    func load(_ questions: [Question]) {
        cards = questions
        topCardIndex = 0
        dragOffset = 0
        isCycling = false
    }

    func removeCurrent() {
        guard !cards.isEmpty else { return }
        cards.remove(at: topCardIndex)
        if topCardIndex >= cards.count { topCardIndex = 0 }
    }

    func dragChanged(_ value: DragGesture.Value) {
        guard !isCycling else { return }
        guard abs(value.translation.width) > abs(value.translation.height) else { return }
        dragOffset = value.translation.width
    }

    func dragEnded(_ value: DragGesture.Value, cardWidth: CGFloat, reduceMotion: Bool) {
        guard !isCycling else { return }
        guard cards.count > 1,
              abs(value.translation.width) > 50,
              abs(value.translation.width) > abs(value.translation.height) else {
            withAnimation(reduceMotion ? nil : .smooth) { dragOffset = 0 }
            return
        }
        cycleCard(direction: value.translation.width < 0 ? -1 : 1,
                  cardWidth: cardWidth,
                  reduceMotion: reduceMotion)
    }

    func cycleCard(direction: CGFloat, cardWidth: CGFloat, reduceMotion: Bool) {
        guard !isCycling, cards.count > 1 else { return }
        if reduceMotion {
            topCardIndex = (topCardIndex + 1) % cards.count
            dragOffset = 0
            return
        }

        isCycling = true
        withAnimation(.smooth(duration: direction < 0 ? 0.18 : 0.2), completionCriteria: .removed) {
            dragOffset = direction < 0 ? -cardWidth : cardWidth * 1.33
        } completion: {
            withAnimation(.smooth(duration: 0.5), completionCriteria: .removed) {
                self.topCardIndex = (self.topCardIndex + 1) % self.cards.count
                self.dragOffset = 0
            } completion: {
                self.isCycling = false
            }
        }
    }
}

// MARK: - Card faces

struct QuestionCardFace: View {
    let question: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(question)
                .font(.title2)
                .foregroundStyle(.black)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 24)
        }
        .padding(.horizontal, width * 0.18)
        .padding(.top, height * 0.3)
        .padding(.bottom, 28)
        .frame(width: width, height: height)
        .background(Color(.questionCard), in: .rect(cornerRadius: 36))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }
}

struct AnswerCard: View {
    @Binding var answer: String
    let isFocused: FocusState<Bool>.Binding
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                TextField("Type their answer", text: $answer, axis: .vertical)
                    .font(.body)
                    .foregroundStyle(.black)
                    .tint(.blue)
                    .textFieldStyle(.plain)
                    .lineLimit(1...3)
                    .focused(isFocused)
                    .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isFocused.wrappedValue = false
                                }
                            }
                        }

                Button("Clear answer", systemImage: "xmark.circle.fill") {
                    answer = ""
                    isFocused.wrappedValue = true
                }
                .labelStyle(.iconOnly)
                .font(.title2)
                .foregroundStyle(Color(.answerFieldLine))
                .frame(minWidth: 44, minHeight: 44)
            }

            Rectangle()
                .fill(Color(.answerFieldLine))
                .frame(height: 1)
        }
        .padding(.horizontal, width * 0.13)
        .padding(.vertical, 24)
        .frame(width: width, height: height)
        .background(Color(.answerCard), in: .rect(cornerRadius: 22))
    }
}

// MARK: - The deck

struct QuestionCardDeck: View {
    @ObservedObject var deck: QuestionDeckState
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let flipAngle: Double
    let isAnswering: Bool

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

                QuestionCardFace(question: card.text, width: cardWidth, height: cardHeight)
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
