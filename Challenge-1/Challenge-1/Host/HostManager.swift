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
    @Published var statusText = "Waiting for players…"
    @Published var isConnected = false

    private var listener: NWListener?
    private var connection: NWConnection?

    func startLobby(name: String) {
        guard listener == nil else { return }

        do {
            let listener = try NWListener(using: .tcp)
            listener.service = NWListener.Service(name: name, type: "_trivianetwork._tcp")

            listener.stateUpdateHandler = { state in
                print("Listener state: \(state)")
            }

            listener.newConnectionHandler = { [weak self] newConnection in
                self?.accept(newConnection)
            }

            listener.start(queue: .main)
            self.listener = listener
        } catch {
            statusText = "Could not start lobby"
            print("Listener error: \(error)")
        }
    }

    private func accept(_ newConnection: NWConnection) {
        guard connection == nil else {
            newConnection.cancel()
            return
        }

        connection = newConnection

        newConnection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.isConnected = true
                self?.statusText = "Player connected"
            case .failed, .cancelled:
                self?.connection = nil
                self?.isConnected = false
                self?.statusText = "Waiting for players…"
            default:
                break
            }
        }

        newConnection.start(queue: .main)
    }

    func stop() {
        connection?.cancel()
        connection = nil
        listener?.cancel()
        listener = nil
        isConnected = false
        statusText = "Waiting for players…"
    }
}
