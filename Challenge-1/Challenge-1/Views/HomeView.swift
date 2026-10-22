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
    @State private var showHelp = false
    @State private var showJoinSheet = false
    @State private var pendingHost: HostRequest?
    @State private var pendingLobby: Lobby?

    private struct HostRequest {
        let name: String
        let settings: GameSettings
    }
    

    var body: some View {
        VStack(spacing: 16) {
            HomeCardShowcase()

            Text("UGuess")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(.black)

            Spacer().frame(height: 24)

            LobbyPillButton(title: "Create a Lobby", action: { showHostSheet = true },font: .title3, style: .primary)
            LobbyPillButton(title: "Join a Lobby", action: { showJoinSheet = true },font: .title3, style: .dark)
        }
        .padding(.horizontal, 40)
        .padding(.top, 70)
        .padding(.bottom, 60)
        .overlay(alignment: .topTrailing) {
            CircularIconButton(title: "How to play", systemImage: "questionmark",
                               action: { showHelp = true }, diameter: 48)
                .padding(.top, 16)
                .padding(.trailing, 24)
        }
        .fullScreenCover(isPresented: $showHelp) {
            OnboardingView(buttonTitle: "Got it") { showHelp = false }
        }
        .sheet(isPresented: $showHostSheet, onDismiss: hostSheetDismissed) {
            HostSheet(session: session) { name, settings in
                pendingHost = HostRequest(name: name, settings: settings)
                showHostSheet = false
            }
        }
        .sheet(isPresented: $showJoinSheet, onDismiss: joinSheetDismissed) {
            JoinSheet(joiner: joiner, session: session) { lobby in
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

private struct HomeCardShowcase: View {
    @StateObject private var deck = CardDeckState<Question>()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let cardsPerDeck = 2

    private var sampleCards: [Question] {
        (0..<cardsPerDeck).flatMap { index in
            GameDifficulty.allCases.compactMap { level -> Question? in
                let questions = QuestionBank.questions(for: level)
                return index < questions.count ? questions[index] : nil
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width * 0.62,
                            geometry.size.height / 1.35 * 0.85,
                            260)
            let height = width * 1.35

            CardDeck(
                deck: deck,
                cardWidth: width,
                cardHeight: height,
                flipAngle: 0,
                isAnswering: false,
                onTap: { },
                cardAccessibilityLabel: { $0.text }
            ) { card in
                QuestionCardFace(question: card.text, difficulty: card.difficulty,
                                 width: width, height: height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)
            .task {
                if deck.cards.isEmpty { deck.load(sampleCards) }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(2.5))
                    deck.cycleCard(direction: -1, cardWidth: width,
                                   reduceMotion: reduceMotion)
                }
            }
        }
    }
}

private struct SheetHeader: View {
    @ObservedObject var session: GameSession
    let onClose: () -> Void

    @State private var showRename = false
    @State private var draftName = ""

    private var tint: LinearGradient {
        LinearGradient(
            colors: [Color(hex: 0x3B86C7).opacity(0.35), .clear, Color(hex: 0xAE2C24).opacity(0.3)],
            startPoint: .leading, endPoint: .trailing
        )
    }

    var body: some View {
        HStack(spacing: 16) {
            colorMenu

            VStack(alignment: .leading, spacing: 2) {
                Text("Playing as").font(.footnote)
                Button {
                    draftName = session.myName
                    showRename = true
                } label: {
                    HStack(spacing: 6) {
                        Text(session.myDisplayName).font(.title2.bold()).lineLimit(1)
                        Image(systemName: "pencil").font(.footnote)
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 12)

            CircularIconButton(title: "Close", systemImage: "xmark", action: onClose,
                               backgroundColor: .white.opacity(0.7), diameter: 48)
        }
        .padding(20)
        .background(tint)
        .alert("Your name", isPresented: $showRename) {
            TextField("Name", text: $draftName)
            Button("Cancel", role: .cancel) { }
            Button("Save") { session.setName(draftName) }
        } message: {
            Text("The other player will see this name.")
        }
    }

    private var colorMenu: some View {
        Menu {
            Picker("Color", selection: avatarBinding) {
                ForEach(AvatarColor.allCases) { option in
                    Label { Text(option.title) } icon: { option.menuIcon }
                        .tag(option)
                }
            }
        } label: {
            AvatarView(initials: session.myDisplayName.initials,
                       color: session.myAvatar, size: 64)
        }
    }

    private var avatarBinding: Binding<AvatarColor> {
        Binding(
            get: { session.myAvatar },
            set: { session.setAvatar($0) }
        )
    }
}

// MARK: - Host sheet

private struct HostSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var session: GameSession
    @State private var name = ""
    @State private var difficulty: GameDifficulty = .easy
    @State private var questions = 1
    let onStart: (String, GameSettings) -> Void

    private var cleanName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(session: session) { dismiss() }

            Divider()

            VStack(spacing: 20) {
                TextField("Lobby name", text: $name)
                    .padding(14)
                    .background(.white, in: .rect(cornerRadius: 16))

                settings

                Spacer(minLength: 16)

                LobbyPillButton(title: "Create a Room", action: start,
                                font: .title3, style: .primary)
                    .disabled(cleanName.isEmpty)
                    .opacity(cleanName.isEmpty ? 0.4 : 1)
            }
            .padding(24)
        }
        .foregroundStyle(.black)
        .presentationDetents([.medium, .large])
        .presentationBackground(Color(hex: 0xF8F8F8))
        .preferredColorScheme(.light)
    }

    private var settings: some View {
        VStack(spacing: 0) {
            HStack {
                Label("Decks", systemImage: "square.stack")
                Spacer()
                Picker("Decks", selection: $difficulty) {
                    ForEach(GameDifficulty.allCases) { level in
                        Text(level.title).tag(level)
                    }
                }
                .labelsHidden()
                .tint(.black)
            }
            .padding(16)

            Divider()

            HStack {
                Label("Questions", systemImage: "questionmark.circle")
                Spacer()
                OptionStepper(value: $questions, range: 1...10)
            }
            .padding(16)
        }
        .background(.white, in: .rect(cornerRadius: 24))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }

    private func start() {
        onStart(cleanName, GameSettings(difficulty: difficulty, rounds: questions))
    }
}

// MARK: - Join sheet

private struct JoinSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var joiner: JoinManager
    @ObservedObject var session: GameSession
    let onSelect: (Lobby) -> Void

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(session: session) { dismiss() }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Friends' rooms")
                        .font(.title.bold())

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                              spacing: 28) {
                        ForEach(joiner.lobbies) { lobby in
                            Button { onSelect(lobby) } label: {
                                VStack(spacing: 10) {
                                    Circle()
                                        .fill(Color.gray.opacity(0.4))
                                        .frame(width: 92, height: 92)
                                    Text(lobby.lobbyName)
                                        .font(.footnote.bold())
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                                .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                        }

                        ProgressView()
                            .controlSize(.large)
                            .frame(width: 92, height: 92)
                    }
                }
                .padding(24)
            }

            LobbyPillButton(title: "Search again", action: {
                joiner.stopBrowsing()
                joiner.startBrowsing()
            }, font: .title3)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .foregroundStyle(.black)
        .onAppear { joiner.startBrowsing() }
        .onDisappear { joiner.stopBrowsing() }
        .presentationDetents([.large])
        .presentationBackground(Color(hex: 0xF8F8F8))
        .preferredColorScheme(.light)
    }
}

struct OnboardingView: View {
    let buttonTitle: LocalizedStringKey
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Welcome to").foregroundStyle(.black.opacity(0.6))
                    Text("UGuess").foregroundStyle(.black)
                }
                .font(.largeTitle.bold())

                Text("This game is about getting to know each other through random questions. Play together, compare your answers and have fun.")
                    .foregroundStyle(.black)

                step(icon: "person.2.fill", title: "How to Start",
                     text: "Create a room or join your friend's game. All you need is the two of you!")
                step(icon: "square.stack", title: "Decks and Questions",
                     text: "Choose a deck that matches your friendship and decide how many questions to play.")
                step(icon: "text.bubble", title: "Answer and Compare",
                     text: "Tap a card and answer it the way your friend would. When you both finish, you see each other's answers.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 80)
            .padding(.bottom, 32)
        }
        .safeAreaInset(edge: .bottom) {
            LobbyPillButton(title: buttonTitle, action: onContinue,
                            font: .headline, minimumHeight: 56, style: .primary)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
        }
        .lobbyScreen()
    }

    private func step(icon: String, title: LocalizedStringKey,
                      text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(.black.opacity(0.6))
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundStyle(.black)
                Text(text)
                    .font(.body)
                    .foregroundStyle(.black.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
