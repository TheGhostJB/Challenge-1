//
//  ReviewView.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 20/10/2026.
//

import SwiftUI

struct ReviewView: View {
    @ObservedObject var session: GameSession

    @State private var showLeave = false
    @State private var showEnd = false

    private var isHost: Bool { session.role == .host }

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                Text("\(session.opponentDisplayName)'s answers")
                    .font(.title2.bold())
                    .foregroundStyle(.black)
                Spacer(minLength: 16)
                CircularIconButton(title: "Leave game", systemImage: "xmark",
                                   action: { showLeave = true }, diameter: 62)
            }

            content

            if isHost {
                LobbyPillButton(title: "END GAME", action: { showEnd = true }, font: .title3)
            } else {
                Text("The host will end the game")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .confirmationPopup(isPresented: $showLeave,
                           message: "Are you sure you want to leave the game?") {
            session.leave()
        }
        .confirmationPopup(isPresented: $showEnd,
                           message: "Are you sure you want to end the game?",
                           confirmTitle: "End game") {
            session.endGame()
        }
    }

    @ViewBuilder
    private var content: some View {
        if session.isWaitingForOpponent {
            VStack(spacing: 16) {
                Spacer()
                ProgressView()
                Text("Waiting for the other player to finish…")
                    .font(.headline)
                    .foregroundStyle(.black)
                Spacer()
            }
        } else {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(session.opponentReview ?? []) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.question)
                                .font(.headline)
                            Text(item.answer)
                                .font(.body)
                        }
                        .foregroundStyle(.black)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: 0xF3F2F7), in: .rect(cornerRadius: 20))
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
