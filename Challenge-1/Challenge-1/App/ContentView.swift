//
//  ContentView.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 12/10/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var session = GameSession()

    @AppStorage("isOnboardingCompleted") private var isOnboardingCompleted = false

    var body: some View {

        if isOnboardingCompleted {
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
        else {
            OnboardingView(buttonTitle: "Continue", onContinue: completeOnboarding)
        }
    }

    private func completeOnboarding() {
        isOnboardingCompleted = true
    }
}

#Preview {
    ContentView()
}
