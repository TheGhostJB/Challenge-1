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

