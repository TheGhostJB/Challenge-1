//
//  LobbyManager.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 15/10/2026.
//

import Foundation
import Network

struct Lobby: Identifiable {
    let lobbyName: String
    let endpoint: NWEndpoint
    var id: String { lobbyName }
}
