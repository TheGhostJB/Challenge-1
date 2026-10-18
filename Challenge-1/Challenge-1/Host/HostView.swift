//
//  HostView.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 14/10/2026.
//

import SwiftUI

struct HostView: View {
    @State private var hostName = ""
    @State private var lobbyStarted = false
    @StateObject private var network = HostManager()
    let onStop: () -> Void

    private var canStart: Bool {
        !hostName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if lobbyStarted {
                    VStack(spacing: 12) {
                        Text(network.statusText)
                    }
                } else {
                    VStack(spacing: 16) {
                        TextField("Lobby name", text: $hostName)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { createLobby() }

                        Button("Start Lobby") { createLobby() }
                            .buttonStyle(.borderedProminent)
                            .disabled(!canStart)
                    }
                    .padding(.horizontal, 40)
                }
            }
            .navigationTitle("Host")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        network.stop()
                        onStop()
                    }
                }
            }
        }
    }

    private func createLobby() {
        guard canStart else { return }
        network.startLobby(name: hostName.trimmingCharacters(in: .whitespaces))
        lobbyStarted = true
    }
}

#Preview {
    HostView(onStop: { })
}
