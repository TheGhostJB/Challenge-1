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
    let question: String
    @Binding var answer: String
    let isFocused: FocusState<Bool>.Binding
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Text(question)
                .font(.headline)
                .foregroundStyle(.black.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 24)
            
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
            
            Spacer(minLength: 24)
        }
        .padding(.horizontal, width * 0.13)
        .padding(.vertical, 24)
        .frame(width: width, height: height)
        .background(Color(.answerCard), in: .rect(cornerRadius: 22))
    }
}
