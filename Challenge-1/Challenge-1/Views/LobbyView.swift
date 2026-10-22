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
    @State private var showRename = false
    @State private var draftName = ""

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
        .alert("Your name", isPresented: $showRename) {
            TextField("Name", text: $draftName)
            Button("Cancel", role: .cancel) { }
            Button("Save") { session.setName(draftName) }
        } message: {
            Text("The other player will see this name.")
        }
    }

    // MARK: Pieces

    private var participants: some View {
        VStack(spacing: 16) {
            LobbyParticipantRow(name: hostRowName, isReady: false, showsReadyBadge: false,
                                avatarColor: hostRowColor, onEdit: hostRowEdit)

            if session.isPeerConnected {
                LobbyParticipantRow(name: joinerRowName, isReady: session.isJoinerReady,
                                    avatarColor: joinerRowColor, onEdit: joinerRowEdit)
            } else {
                LobbyParticipantRow(name: "Waiting…", isReady: false,
                                    showsReadyBadge: false, isSearching: true)
            }
        }
    }
    
    private var hostRowName: String {
        isHost ? session.myDisplayName : session.opponentDisplayName
    }

    private var joinerRowName: String {
        isHost ? session.opponentDisplayName : session.myDisplayName
    }

    private var hostRowEdit: (() -> Void)? {
        if isHost { return { editName() } }
        return nil
    }
    
    private var hostRowColor: AvatarColor {
        isHost ? session.myAvatar : session.opponentAvatar
    }

    private var joinerRowColor: AvatarColor {
        isHost ? session.opponentAvatar : session.myAvatar
    }

    private var joinerRowEdit: (() -> Void)? {
        if isHost { return nil }
        return { editName() }
    }
    
    private func editName() {
        draftName = session.myDisplayName
        showRename = true
    }

    private var details: some View {
        VStack(spacing: 12) {
            if isHost {
                Menu {
                    ForEach(GameDifficulty.allCases) { level in
                        Button { change(difficulty: level) } label: { Text(level.title) }
                    }
                } label: {
                    settingPill("Decks: \(deckTitle)", isEditable: true)
                }

                HStack {
                    Text("Questions").font(.subheadline)
                    Spacer()
                    OptionStepper(value: questionsBinding, range: 1...10)
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, minHeight: 44)
                .glassCapsule()
            } else {
                settingPill("Decks: \(deckTitle)", isEditable: false)
                settingPill("Questions: \(session.settings.rounds)", isEditable: false)
            }
        }
    }

    private var deckTitle: String {
        String(localized: session.settings.difficulty.title)
    }

    private var questionsBinding: Binding<Int> {
        Binding(
            get: { session.settings.rounds },
            set: { change(rounds: $0) }
        )
    }

    @ViewBuilder
    private func settingPill(_ title: String, isEditable: Bool) -> some View {
        let label = HStack(spacing: 8) {
            Text(title)
            if isEditable {
                Image(systemName: "chevron.up.chevron.down").font(.footnote)
            }
        }
        .font(.subheadline)
        .foregroundStyle(.black.opacity(isEditable ? 1 : 0.45))
        .frame(maxWidth: .infinity, minHeight: 44)

        if isEditable {
            label.glassCapsule()
        } else {
            label.background(.white.opacity(0.25), in: .capsule)
        }
    }

    @ViewBuilder
    private var actions: some View {
        if isHost {
            VStack(spacing: 16) {
                if !session.canStart {
                    Text(session.isPeerConnected ? "Waiting for the player to be ready"
                                                 : "Waiting for a player to join")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }

                LobbyPillButton(title: "START", action: session.startGame, font: .title3, style: .primary)
                    .disabled(!session.canStart)
                    .opacity(session.canStart ? 1 : 0.4)
            }
        } else {
            LobbyPillButton(title: session.isJoinerReady ? "NOT READY" : "READY",
                            action: { session.setReady(!session.isJoinerReady) },
                            font: .title3,
                            style: session.isJoinerReady ? .secondary : .ready)
        }
    }

    private func change(difficulty: GameDifficulty) {
        session.updateSettings(GameSettings(difficulty: difficulty, rounds: session.settings.rounds))
    }

    private func change(rounds: Int) {
        session.updateSettings(GameSettings(difficulty: session.settings.difficulty, rounds: rounds))
    }
}
