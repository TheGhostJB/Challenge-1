//
//  HomeView.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 20/10/2026.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var session: GameSession
    @ObservedObject var joiner: JoinManager

    @State private var showHostSheet = false
    @State private var showJoinSheet = false
    @State private var pendingHost: HostRequest?
    @State private var pendingLobby: Lobby?

    private struct HostRequest {
        let name: String
        let settings: GameSettings
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("Trivia Game")
                .font(.largeTitle.bold())
                .foregroundStyle(.black)

            Spacer()

            LobbyPillButton(title: "Create a Lobby", action: { showHostSheet = true }, font: .title3)
            LobbyPillButton(title: "Join a Lobby", action: { showJoinSheet = true }, font: .title3)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 60)
        .sheet(isPresented: $showHostSheet, onDismiss: hostSheetDismissed) {
            HostSheet { name, settings in
                pendingHost = HostRequest(name: name, settings: settings)
                showHostSheet = false
            }
        }
        .sheet(isPresented: $showJoinSheet, onDismiss: joinSheetDismissed) {
            JoinSheet(joiner: joiner) { lobby in
                pendingLobby = lobby
                showJoinSheet = false
            }
        }
    }

    private func hostSheetDismissed() {
        guard let request = pendingHost else { return }
        pendingHost = nil
        session.startHosting(name: request.name, settings: request.settings)
    }

    private func joinSheetDismissed() {
        guard let lobby = pendingLobby else { return }
        pendingLobby = nil
        session.join(lobby)
    }
}

// MARK: - Host sheet

private struct HostSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var difficulty: GameDifficulty = .easy
    @State private var rounds = 3
    let onStart: (String, GameSettings) -> Void

    private var cleanName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("New lobby")
                    .font(.title2.bold())
                Spacer()
                CircularIconButton(title: "Close", systemImage: "xmark",
                                   action: { dismiss() },
                                   foregroundColor: .white,
                                   backgroundColor: Color(.hostCloseBackground))
            }

            TextField("Lobby name", text: $name)
                .textFieldStyle(.roundedBorder)

            VStack(spacing: 0) {
                HStack {
                    Label("Difficulty", systemImage: "flag.checkered")
                    Spacer()
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(GameDifficulty.allCases) { level in
                            Text(level.title).tag(level)
                        }
                    }
                    .labelsHidden()
                    .tint(.black)
                }
                .padding(16)

                Divider().overlay { Color(.lobbyIcon) }

                HStack {
                    Label("Rounds", systemImage: "questionmark.circle")
                    Spacer()
                    Picker("Rounds", selection: $rounds) {
                        ForEach([3, 5, 10], id: \.self) { count in
                            Text("\(count)").tag(count)
                        }
                    }
                    .labelsHidden()
                    .tint(.black)
                }
                .padding(16)
            }
            .background(Color(.hostSettingsBackground), in: .rect(cornerRadius: 12))

            Spacer(minLength: 16)

            LobbyPillButton(title: "Start", action: start)
                .disabled(cleanName.isEmpty)
                .opacity(cleanName.isEmpty ? 0.4 : 1)
        }
        .foregroundStyle(.black)
        .padding(30)
        .presentationDetents([.medium, .large])
        .presentationBackground(Color(.lobbyCard))
        .preferredColorScheme(.light)
    }

    private func start() {
        onStart(cleanName, GameSettings(difficulty: difficulty, rounds: rounds))
    }
}

// MARK: - Join sheet

private struct JoinSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var joiner: JoinManager
    let onSelect: (Lobby) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Active lobbies")
                        .font(.title2.bold())
                    Spacer()
                    CircularIconButton(title: "Close", systemImage: "xmark",
                                       action: { dismiss() },
                                       foregroundColor: .white,
                                       backgroundColor: Color(.hostCloseBackground))
                }

                Divider().overlay { Color(.lobbyIcon) }

                if joiner.lobbies.isEmpty {
                    Text("Searching…")
                        .foregroundStyle(.gray)
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                          spacing: 28) {
                    ForEach(joiner.lobbies) { lobby in
                        Button { onSelect(lobby) } label: {
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(Color(.lobbyIcon))
                                    .frame(width: 70, height: 70)
                                Text(lobby.lobbyName)
                                    .font(.caption.bold())
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                }

                LobbyPillButton(title: "Search again") {
                    joiner.stopBrowsing()
                    joiner.startBrowsing()
                }
                .padding(.top, 24)
            }
            .foregroundStyle(.black)
            .padding(24)
        }
        .onAppear { joiner.startBrowsing() }
        .onDisappear { joiner.stopBrowsing() }
        .presentationDetents([.large])
        .presentationBackground(Color(.lobbyCard))
        .preferredColorScheme(.light)
    }
}
