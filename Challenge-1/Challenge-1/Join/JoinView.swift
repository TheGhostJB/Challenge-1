//
//  JoinView.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 14/10/2026.
//

import SwiftUI

struct JoinView: View {
    @StateObject private var network = JoinManager()
    @State private var selectedLobby: Lobby?
    @State private var showConfirm = false
    let onStop: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if network.isConnected {
                    Text(network.statusText)
                } else if network.lobbies.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Searching for lobbies…")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List(network.lobbies) { lobby in
                        Button {
                            selectedLobby = lobby
                            showConfirm = true
                        } label: {
                            Text(lobby.lobbyName)
                        }
                    }
                }
            }
            .navigationTitle("Join")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        network.disconnect()
                        onStop()
                    }
                }
            }
            .confirmationDialog(
                "Join this lobby?",
                isPresented: $showConfirm,
                presenting: selectedLobby
            ) { lobby in
                Button("Join \(lobby.lobbyName)") {
                    network.connect(to: lobby)
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .onAppear { network.startBrowsing() }
        .onDisappear { network.stopBrowsing() }
    }
}

#Preview {
    JoinView(onStop: { })
}
