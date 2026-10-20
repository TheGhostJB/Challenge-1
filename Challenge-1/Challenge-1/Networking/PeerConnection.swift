//
//  PeerConnection.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 19/10/2026.
//

import Foundation
import Network

final class PeerConnection {
    private let connection: NWConnection
    private var buffer = Data()
    private var didClose = false

    var onReady: (() -> Void)?
    var onMessage: ((Message) -> Void)?
    var onClose: (() -> Void)?

    init(_ connection: NWConnection) {
        self.connection = connection
    }

    func start() {
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.onReady?()
                self?.receive()
            case .failed, .cancelled:
                self?.finish()
            default:
                break
            }
        }
        connection.start(queue: .main)
    }

    func send(_ message: Message) {
        guard let body = try? JSONEncoder().encode(message) else { return }

        var frame = withUnsafeBytes(of: UInt32(body.count).bigEndian) { Data($0) }
        frame.append(body)

        connection.send(content: frame, completion: .contentProcessed { [weak self] error in
            if error != nil { self?.finish() }
        })
    }

    func close() {
        didClose = true
        onReady = nil
        onMessage = nil
        onClose = nil
        connection.cancel()
    }

    private func receive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self, !self.didClose else { return }

            if let data, !data.isEmpty {
                self.buffer.append(data)
                self.processBuffer()
            }

            if isComplete || error != nil {
                self.finish()
            } else {
                self.receive()
            }
        }
    }

    private func processBuffer() {
        while buffer.count >= 4 {
            let length = buffer.prefix(4).reduce(0) { ($0 << 8) | Int($1) }

            guard length <= 1_000_000 else {
                finish()
                return
            }
            guard buffer.count >= 4 + length else { return }

            let body = Data(buffer.dropFirst(4).prefix(length))
            buffer = Data(buffer.dropFirst(4 + length))

            if let message = try? JSONDecoder().decode(Message.self, from: body) {
                onMessage?(message)
            } else {
                print("Could not decode a message")
            }
        }
    }

    private func finish() {
        guard !didClose else { return }
        didClose = true
        connection.cancel()
        onClose?()
    }
}
