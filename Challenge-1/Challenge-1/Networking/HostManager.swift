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
    
    var isAcceptingPlayers = true
    var onMessage: ((Message) -> Void)?
    var onPlayerJoined: (() -> Void)?
    var onPlayerLeft: (() -> Void)?

    private var listener: NWListener?
    private var peer: PeerConnection?

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
        guard isAcceptingPlayers, peer == nil else {
            newConnection.cancel()
            return
        }

        let peer = PeerConnection(newConnection)
        self.peer = peer

        peer.onReady = { [weak self] in
            self?.isConnected = true
            self?.statusText = "Player connected"
            self?.onPlayerJoined?()
        }
        peer.onMessage = { [weak self] message in
            self?.onMessage?(message)
        }
        peer.onClose = { [weak self] in
            self?.peer = nil
            self?.isConnected = false
            self?.statusText = "Waiting for players…"
            self?.onPlayerLeft?()
        }
        peer.start()
    }

    func send(_ message: Message) {
        peer?.send(message)
    }

    func stop() {
        peer?.close()
        peer = nil
        listener?.cancel()
        listener = nil
        isConnected = false
        statusText = "Waiting for players…"
    }
}
