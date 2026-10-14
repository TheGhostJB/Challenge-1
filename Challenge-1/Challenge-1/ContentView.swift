//
//  ContentView.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 12/10/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var role: Role?
    
    enum  Role { case host, join }
    
    var body: some View {
        switch role {
        case .host:
            HostView()
        case .join:
            JoinView()
        case .none:
            VStack (spacing:0){
                Spacer()
                
                HStack {
                        Spacer()
                        Button { } label: {
                            Text("?")
                                .frame(width: 50, height: 30)
                                .foregroundColor(Color.white)
                                .background(Color.purple)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 40)
                    }
                
                VStack (spacing: 8){
                    Text("Trivia Game")
                        .font(.largeTitle.bold())
                        .padding(.bottom, 370)
                }
                
                Spacer()
                
                VStack (spacing: 12){
                    Button { role = .host} label: {
                        Text("Host")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .controlSize(.large)
                    .padding(.bottom, 20)
                    
                    
                    Button {role = .join } label: {
                        Text("Join")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .controlSize(.large)
                    .padding(.bottom, 60)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    ContentView()
}
