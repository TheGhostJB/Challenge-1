//
//  HostManager.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 14/10/2026.
//

import Network
import Foundation
import Combine


class HostManager: ObservableObject {
    @Published var statusText = "Waiting for connection…"
    @Published var isConnected = false
    @Published var localIP: String = "…"
    
    private var listener: NWListener?
    private var connection: NWConnection?
    private let port: NWEndpoint.Port = 8080
    
    init() {
        localIP = getLocalIP()
        startListening()
    }
}
