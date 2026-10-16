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

        let browser = NWBrowser(for: .bonjour(type: "_trivianetwork._tcp", domain: nil), using: .tcp)
        self.browser = browser
        browser.browseResultsChangedHandler = { [weak self] results, _ in
            guard let result = results.first else { return }
            self?.browser?.cancel()
            self?.browser = nil
            self?.isSearching = false
            self?.connectTo(result.endpoint)
        }
        browser.start(queue: .main)
    }
    
    func stopBrowsing() {
        browser?.cancel()
        browser = nil
        connection?.cancel()
        connection = nil
        isConnected = false
        isSearching = false
        statusText = "Disconnected"
    }


}
