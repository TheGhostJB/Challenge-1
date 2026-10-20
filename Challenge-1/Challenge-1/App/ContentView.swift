//
//  ContentView.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 12/10/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var session = GameSession()

    var body: some View {
        Group {
            switch session.phase {
            case .home:
                HomeView(session: session, joiner: session.joiner)
            case .lobby:
                LobbyView(session: session)
            case .playing:
                PlayView(session: session)
            case .review:
                ReviewView(session: session)
            }
        }
        .lobbyScreen()
        .animation(.easeInOut(duration: 0.25), value: session.phase)
    }
}

#Preview {
    ContentView()
}
