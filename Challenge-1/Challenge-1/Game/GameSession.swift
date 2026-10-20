//
//  GameSession.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 19/10/2026.
//

import Foundation
import Combine

enum PlayerRole {
    case host
    case joiner
}

enum GamePhase {
    case home
    case lobby
    case playing
    case review
}

struct ReviewItem: Identifiable {
    let id: Int
    let question: String
    let answer: String
}

final class GameSession: ObservableObject {
    let host = HostManager()
    let joiner = JoinManager()

    @Published private(set) var role: PlayerRole?
    @Published private(set) var myName = ""
    @Published private(set) var opponentName: String?
    @Published private(set) var phase: GamePhase = .home
    @Published private(set) var lobbyName = ""
    @Published private(set) var settings = GameSettings.standard
    @Published private(set) var isPeerConnected = false
    @Published private(set) var isJoinerReady = false

    @Published private(set) var questions: [Question] = []
    @Published private(set) var myAnswers: [AnswerEntry] = []
    @Published private(set) var iFinished = false
    @Published private(set) var opponentResults: [AnswerEntry]? = nil

    init() {
        host.onPlayerJoined = { [weak self] in self?.playerJoined() }
        host.onMessage = { [weak self] message in self?.handle(message) }
        host.onPlayerLeft = { [weak self] in self?.peerDisconnected() }

        joiner.onConnected = { [weak self] in self?.joinerConnected() }
        joiner.onMessage = { [weak self] message in self?.handle(message) }
        joiner.onHostLeft = { [weak self] in self?.peerDisconnected() }
    }
    
    var canStart: Bool {
        role == .host && phase == .lobby && isPeerConnected && isJoinerReady
    }

    var isWaitingForOpponent: Bool {
        iFinished && opponentResults == nil
    }
    
    var myDisplayName: String {
        myName.isEmpty ? (role == .host ? "Host" : "Player") : myName
    }

    var opponentDisplayName: String {
        opponentName ?? (role == .host ? "Player" : "Host")
    }
    
    func setName(_ newName: String) {
        let clean = String(newName.trimmingCharacters(in: .whitespacesAndNewlines).prefix(20))
        myName = clean
        if isPeerConnected { send(.name(myDisplayName)) }
    }

    private func joinerConnected() {
        isPeerConnected = true
        send(.name(myDisplayName))
    }

    var opponentReview: [ReviewItem]? {
        guard let results = opponentResults else { return nil }
        return results.map { entry in
            ReviewItem(
                id: entry.questionID,
                question: QuestionBank.question(withID: entry.questionID)?.text ?? "Unknown question",
                answer: entry.answer
            )
        }
    }
    
    func startHosting(name: String, settings: GameSettings) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }

        host.isAcceptingPlayers = true
        role = .host
        lobbyName = cleanName
        self.settings = settings
        phase = .lobby
        host.startLobby(name: cleanName)
    }

    func join(_ lobby: Lobby) {
        role = .joiner
        lobbyName = lobby.lobbyName
        phase = .lobby
        joiner.connect(to: lobby)
    }

    func setReady(_ isReady: Bool) {
        guard role == .joiner else { return }
        isJoinerReady = isReady
        send(.ready(isReady))
    }

    func updateSettings(_ newSettings: GameSettings) {
        guard role == .host, phase == .lobby else { return }
        settings = newSettings
        isJoinerReady = false
        send(.settings(newSettings))
    }

    func startGame() {
        guard canStart else { return }
        send(.start)
        beginPlaying()
    }

    func submitAnswer(questionID: Int, answer: String) {
        guard phase == .playing, !iFinished else { return }

        let entry = AnswerEntry(questionID: questionID, answer: answer)
        if let index = myAnswers.firstIndex(where: { $0.questionID == questionID }) {
            myAnswers[index] = entry
        } else {
            myAnswers.append(entry)
        }

        if myAnswers.count >= settings.rounds {
            finishPlaying()
        }
    }

    func endGame() {
        guard role == .host else { return }
        send(.endGame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.leaveToHome()
        }
    }

    func leave() {
        leaveToHome()
    }
    
    private func playerJoined() {
        isPeerConnected = true
        send(.settings(settings))
        send(.name(myDisplayName))
    }

    private func handle(_ message: Message) {
        switch message {
        case .settings(let newSettings):
            settings = newSettings
            isJoinerReady = false
        case .ready(let isReady):
            isJoinerReady = isReady
        case .name(let name):
            opponentName = name
        case .start:
            beginPlaying()
        case .results(let answers):
            opponentResults = answers
        case .endGame:
            leaveToHome()
        }
    }
    
    private func beginPlaying() {
        host.isAcceptingPlayers = false
        questions = QuestionBank.questions(for: settings.difficulty).shuffled()
        myAnswers = []
        iFinished = false
        opponentResults = nil
        phase = .playing
    }

    private func finishPlaying() {
        iFinished = true
        phase = .review
        send(.results(myAnswers))
    }
    
    private func peerDisconnected() {
        isPeerConnected = false
        isJoinerReady = false

        switch phase {
        case .home:
            break
        case .lobby:
            if role == .joiner { leaveToHome() }
        case .playing:
            leaveToHome()
        case .review:
            if !iFinished || opponentResults == nil { leaveToHome() }
        }
    }

    private func leaveToHome() {
        host.stop()
        joiner.disconnect()
        role = nil
        phase = .home
        lobbyName = ""
        settings = GameSettings.standard
        isPeerConnected = false
        isJoinerReady = false
        questions = []
        myAnswers = []
        iFinished = false
        opponentResults = nil
        opponentName = nil
    }

    private func send(_ message: Message) {
        switch role {
        case .host:
            host.send(message)
        case .joiner:
            joiner.send(message)
        case .none:
            break
        }
    }
}
