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
        else{

            ScrollView{

                VStack (alignment: .leading, spacing: 36) {

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Welcome to")
                            .foregroundStyle(.secondary)


                        Text("Trivia Game")
                            .foregroundStyle(.primary)
                    }
                    .font(.largeTitle.bold())

                    Text("""
                        
                    This game is about getting to know each other through random questions. 
                    Play together, compare your answer and have fun.
                    
                    """)
                    

                    HStack(alignment: .top, spacing: 20){

                        Image(systemName: "person.2.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .frame(width: 50)

                        VStack (alignment: .leading, spacing: 4) {
                            Text("How to Start")
                                .font(.headline)

                            Text("""

                            Create a room or join your friend’s game. All you need is the two of you!

                            """)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        }


                    }
                    .frame(maxWidth: .infinity, alignment: .leading)


                    HStack(alignment: .top, spacing: 20){

                        Image(systemName: "questionmark")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .frame(width: 50)

                        VStack (alignment: .leading, spacing: 4) {
                            Text("Difficulty and Rounds")
                                .font(.headline)

                            Text("""
                            
                            Choose a deck that matches your friendship and decide how many rounds to play.

                            """)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        }


                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top, 80)
                .padding(.bottom, 32)
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: completeOnboarding) {
                    Text("Continua")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(white: 0.2), in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                .padding(.top, 16)
                .padding(.bottom, 16)
                .background(.white)
            }
            .background {
                Color.white.ignoresSafeArea()
            }
            .preferredColorScheme(.light)


        }

    }

    private func completeOnboarding() {
        isOnboardingCompleted = true
    }
}

#Preview {
    ContentView()
}
