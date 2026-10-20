//
//  JoinManager.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 14/10/2026.
//

import Foundation
import Network
import Combine

class JoinManager: ObservableObject {
    @Published var lobbies: [Lobby] = []
    @Published var statusText = "Disconnected"
    @Published var isConnected = false
    @Published var isSearching = false

    var onMessage: ((Message) -> Void)?
    var onHostLeft: (() -> Void)?
    var onConnected: (() -> Void)?

    private var browser: NWBrowser?
    private var peer: PeerConnection?

    func startBrowsing() {
        browser?.cancel()

        let browser = NWBrowser(for: .bonjour(type: "_trivianetwork._tcp", domain: nil), using: .tcp)
        self.browser = browser

        browser.stateUpdateHandler = { state in
            print("Browser state: \(state)")
        }

        browser.browseResultsChangedHandler = { [weak self] results, _ in
            let foundLobbies: [Lobby] = results.compactMap { result in
                if case .service(let name, _, _, _) = result.endpoint {
                    return Lobby(lobbyName: name, endpoint: result.endpoint)
                } else {
                    return nil
                }
            }
            self?.lobbies = foundLobbies
        }

        isSearching = true
        browser.start(queue: .main)
    }

    func stopBrowsing() {
        browser?.cancel()
        browser = nil
        lobbies = []
        isSearching = false
    }

    func connect(to lobby: Lobby) {
        stopBrowsing()
        statusText = "Connecting…"

        let peer = PeerConnection(NWConnection(to: lobby.endpoint, using: .tcp))
        self.peer = peer

        peer.onReady = { [weak self] in
            self?.isConnected = true
            self?.statusText = "Connected to \(lobby.lobbyName)"
            self?.onConnected?()
        }
        peer.onMessage = { [weak self] message in
            self?.onMessage?(message)
        }
        peer.onClose = { [weak self] in
            self?.peer = nil
            self?.isConnected = false
            self?.statusText = "Disconnected"
            self?.onHostLeft?()
        }
        peer.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self, weak peer] in
            guard let self, let peer, self.peer === peer, !self.isConnected else { return }
            self.disconnect()
            self.onHostLeft?()
        }
    }

    func send(_ message: Message) {
        peer?.send(message)
    }

    func disconnect() {
        peer?.close()
        peer = nil
        isConnected = false
        statusText = "Disconnected"
    }
}
