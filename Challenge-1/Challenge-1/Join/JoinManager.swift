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
    
    private var browser: NWBrowser?
    private var connection: NWConnection?
    
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

        let connection = NWConnection(to: lobby.endpoint, using: .tcp)
        self.connection = connection

        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.isConnected = true
                self?.statusText = "Connected to \(lobby.lobbyName)"
            case .waiting:
                self?.statusText = "Waiting…"
            case .failed, .cancelled:
                self?.isConnected = false
                self?.statusText = "Disconnected"
            default:
                break
            }
        }

        connection.start(queue: .main)
    }

    func disconnect() {
        connection?.cancel()
        connection = nil
        isConnected = false
        statusText = "Disconnected"
    }


}
