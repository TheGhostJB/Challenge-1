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
    private var listener: NWListener?
    private var connection: NWConnection?
    private let port: NWEndpoint.Port = 8080
    
    init() {
        
    }
    
    private func startListening() {
        guard let listener = try? NWListener(using: .tcp, on: port) else { return }
        self.listener = listener
        listener.service = NWListener.Service(name: "NetworkDemo", type: "_networkdemo._tcp")
        listener.newConnectionHandler = { [weak self] connection in
            self?.handleIncomingConnection(connection)
        }
        listener.start(queue: .main)
    }
    
    func stop() {
        connection?.cancel()
        listener?.cancel()
    }
    
}
