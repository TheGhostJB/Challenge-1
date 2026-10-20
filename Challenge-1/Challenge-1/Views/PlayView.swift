//
//  PlayView.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 20/10/2026.
//

import SwiftUI

struct PlayView: View {
    @ObservedObject var session: GameSession
    @StateObject private var deck = QuestionDeckState()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showLeave = false
    @State private var isFlipping = false
    @State private var questionAngle: Double = 0
    @State private var answerAngle: Double = -90
    @State private var isAnswerLayout = false
    @State private var isAnswerInputReady = false
    @State private var answer = ""
    @FocusState private var isAnswerFocused: Bool

    private var available: [Question] {
        session.questions.filter { question in
            !session.myAnswers.contains { $0.questionID == question.id }
        }
    }

    private var cleanAnswer: String {
        answer.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            GeometryReader { geometry in
                let width = cardWidth(for: geometry.size.width)

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: isAnswerLayout ? 24 : 40)
                        stage(width: width)
                        Spacer(minLength: 24)
                        controls(cardWidth: width)
                        Spacer(minLength: 40)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .task {
            if deck.cards.isEmpty { deck.load(available) }
        }
        .task(id: isAnswerInputReady) { await focusAnswer() }
        .confirmationPopup(isPresented: $showLeave,
                           message: "Are you sure you want to leave the game?") {
            session.leave()
        }
    }

    // MARK: Pieces

    private var header: some View {
        HStack(alignment: .top) {
            if isAnswerLayout {
                Spacer()
                CircularIconButton(title: "Close answer", systemImage: "xmark",
                                   action: { closeAnswer() }, diameter: 62)
                    .disabled(!isAnswerInputReady)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Choose a question")
                        .font(.title2.bold())
                    Text("Answered \(session.myAnswers.count) of \(session.settings.rounds)")
                        .font(.subheadline)
                }
                .foregroundStyle(.black)

                Spacer(minLength: 16)

                CircularIconButton(title: "Leave game", systemImage: "xmark",
                                   action: { showLeave = true }, diameter: 62)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
    }

    private func stage(width: CGFloat) -> some View {
        let height = cardHeight(for: width)

        return ZStack {
            QuestionCardDeck(deck: deck, cardWidth: width, cardHeight: height,
                             flipAngle: questionAngle, isAnswering: isFlipping)
                .opacity(reduceMotion && isAnswerLayout ? 0 : 1)
                .allowsHitTesting(!isFlipping)

            AnswerCard(answer: $answer, isFocused: $isAnswerFocused,
                       width: width, height: height)
                .rotation3DEffect(.degrees(reduceMotion ? 0 : answerAngle), axis: (x: 0, y: 1, z: 0))
                .opacity(reduceMotion && !isAnswerLayout ? 0 : 1)
                .allowsHitTesting(isAnswerLayout)
        }
        .frame(width: width, height: height)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func controls(cardWidth: CGFloat) -> some View {
        if isAnswerLayout {
            LobbyPillButton(title: "Send Answer", action: sendAnswer, font: .title3)
                .disabled(!isAnswerInputReady || cleanAnswer.isEmpty)
                .opacity(cleanAnswer.isEmpty ? 0.4 : 1)
                .padding(.horizontal, 28)
        } else {
            HStack(spacing: 20) {
                LobbyPillButton(title: "Discard", action: { discardTapped(cardWidth: cardWidth) },
                                font: .title3)
                LobbyPillButton(title: "Answer", action: answerTapped, font: .title3)
            }
            .disabled(deck.isCycling || isFlipping)
            .opacity(isFlipping ? 0 : 1)
            .padding(.horizontal, 28)
        }
    }

    private func cardWidth(for containerWidth: CGFloat) -> CGFloat {
        min(containerWidth * 0.72, 340)
    }

    private func cardHeight(for width: CGFloat) -> CGFloat {
        width * 1.35
    }

    // MARK: Actions

    private func discardTapped(cardWidth: CGFloat) {
        deck.cycleCard(direction: -1, cardWidth: cardWidth, reduceMotion: reduceMotion)
    }

    private func answerTapped() {
        guard !deck.isCycling, !isFlipping, deck.currentCard != nil else { return }
        answer = ""
        isFlipping = true
        if reduceMotion {
            isAnswerLayout = true
            isAnswerInputReady = true
        } else {
            withAnimation(.linear(duration: 0.3), completionCriteria: .removed) {
                questionAngle = 90
            } completion: {
                revealAnswer()
            }
        }
    }

    private func revealAnswer() {
        withAnimation(.linear(duration: 0.3), completionCriteria: .removed) {
            answerAngle = 0
        } completion: {
            arrangeAnswerForEditing()
        }
    }

    private func arrangeAnswerForEditing() {
        withAnimation(.easeInOut(duration: 0.25), completionCriteria: .removed) {
            isAnswerLayout = true
        } completion: {
            isAnswerInputReady = true
        }
    }

    private func focusAnswer() async {
        guard isAnswerInputReady else { return }
        await Task.yield()
        guard !Task.isCancelled else { return }
        isAnswerFocused = true
    }

    private func sendAnswer() {
        guard isAnswerInputReady, let card = deck.currentCard, !cleanAnswer.isEmpty else { return }
        let text = cleanAnswer
        closeAnswer {
            deck.removeCurrent()
            session.submitAnswer(questionID: card.id, answer: text)
        }
    }

    private func closeAnswer(then completion: (() -> Void)? = nil) {
        guard isAnswerInputReady else { return }
        isAnswerInputReady = false
        isAnswerFocused = false
        if reduceMotion {
            finishReturningToDeck(completion)
        } else {
            withAnimation(.linear(duration: 0.3), completionCriteria: .removed) {
                answerAngle = -90
            } completion: {
                revealQuestion(completion)
            }
        }
    }

    private func revealQuestion(_ completion: (() -> Void)?) {
        withAnimation(.linear(duration: 0.3), completionCriteria: .removed) {
            questionAngle = 0
        } completion: {
            finishReturningToDeck(completion)
        }
    }

    private func finishReturningToDeck(_ completion: (() -> Void)?) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            questionAngle = 0
            answerAngle = -90
            isAnswerLayout = false
            isFlipping = false
            answer = ""
        }
        completion?()
    }
}
