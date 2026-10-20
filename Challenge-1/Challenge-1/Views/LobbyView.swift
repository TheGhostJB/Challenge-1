//
//  LobbyView.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 20/10/2026.
//

import SwiftUI

struct LobbyView: View {
    @ObservedObject var session: GameSession
    @State private var showLeave = false

    private var isHost: Bool { session.role == .host }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(session.lobbyName)
                    .font(.title2.bold())
                    .foregroundStyle(.black)
                Spacer(minLength: 16)
                CircularIconButton(title: isHost ? "Close lobby" : "Leave lobby",
                                   systemImage: "xmark",
                                   action: { showLeave = true },
                                   diameter: 62)
            }

            Spacer(minLength: 24)

            participants

            details
                .padding(.top, 24)

            Spacer(minLength: 24)

            actions
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .confirmationPopup(
            isPresented: $showLeave,
            message: isHost ? "Are you sure you want to close the lobby?"
                            : "Are you sure you want to leave the lobby?",
            confirmTitle: isHost ? "Close" : "Leave"
        ) {
            session.leave()
        }
    }

    // MARK: Pieces

    private var participants: some View {
        VStack(spacing: 0) {
            LobbyParticipantRow(name: "Host", isReady: false, showsReadyBadge: false)

            Divider().overlay { Color(.lobbyIcon) }

            if session.isPeerConnected {
                LobbyParticipantRow(name: "Player", isReady: session.isJoinerReady)
            } else {
                LobbyParticipantRow(name: "Waiting for a player…", isReady: false,
                                    showsReadyBadge: false)
            }
        }
        .background(Color(.lobbyCard))
        .clipShape(.rect(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color(.lobbyOutline), lineWidth: 4)
        }
    }

    private var details: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "flag.checkered")
                Text("Difficulty:")
                Text(session.settings.difficulty.title).bold()
                Spacer()
            }
            .padding(16)

            Divider().overlay { Color(.lobbyIcon) }

            HStack {
                Image(systemName: "questionmark.circle")
                Text("Questions:")
                Text("\(session.settings.rounds)").bold()
                Spacer()
            }
            .padding(16)
        }
        .foregroundStyle(.black)
        .background(Color(.joinLobbyDetailsBackground), in: .rect(cornerRadius: 12))
    }

    @ViewBuilder
    private var actions: some View {
        if isHost {
            VStack(spacing: 16) {
                Menu {
                    ForEach(GameDifficulty.allCases) { level in
                        Button { change(difficulty: level) } label: { Text(level.title) }
                    }
                } label: {
                    pill("Change difficulty")
                }

                Menu {
                    ForEach([3, 5, 10], id: \.self) { count in
                        Button("\(count) questions") { change(rounds: count) }
                    }
                } label: {
                    pill("Number of questions")
                }

                if !session.canStart {
                    Text(session.isPeerConnected ? "Waiting for the player to be ready"
                                                 : "Waiting for a player to join")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }

                LobbyPillButton(title: "START", action: session.startGame, font: .title3)
                    .disabled(!session.canStart)
                    .opacity(session.canStart ? 1 : 0.4)
            }
        } else {
            LobbyPillButton(title: session.isJoinerReady ? "NOT READY" : "READY",
                            action: { session.setReady(!session.isJoinerReady) },
                            font: .title3)
        }
    }

    private func pill(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.subheadline)
            .foregroundStyle(.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color(.lobbyIcon), in: .capsule)
    }

    private func change(difficulty: GameDifficulty) {
        session.updateSettings(GameSettings(difficulty: difficulty, rounds: session.settings.rounds))
    }

    private func change(rounds: Int) {
        session.updateSettings(GameSettings(difficulty: session.settings.difficulty, rounds: rounds))
    }
}
