//
//  Components.swift
//  Challenge-1
//
//  Created by Diego Saldana Gomez on 20/10/2026.
//

import SwiftUI

// MARK: - Screen style

struct LobbyScreenStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { Color.white.ignoresSafeArea(edges: [.horizontal, .bottom]) }
            .background { Color(.lobbyStatusBar).ignoresSafeArea() }
            .preferredColorScheme(.light)
    }
}

extension View {
    func lobbyScreen() -> some View { modifier(LobbyScreenStyle()) }
}

// MARK: - Buttons

struct CircularIconButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void
    var foregroundColor: Color = .black
    var backgroundColor: Color = Color(.lobbyCard)
    var diameter: CGFloat = 44

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .font(.system(size: 20))
                .foregroundStyle(foregroundColor)
                .frame(width: diameter, height: diameter)
                .background(backgroundColor, in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
    }
}

struct LobbyPillButton: View {
    let title: LocalizedStringKey
    let action: () -> Void
    var font: Font = .subheadline
    var minimumHeight: CGFloat = 44
    var role: ButtonRole?

    var body: some View {
        Button(role: role, action: action) {
            Text(title)
                .font(font)
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: minimumHeight)
                .background(Color(.lobbyIcon), in: .capsule)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Participant row

struct LobbyParticipantRow: View {
    let name: String
    let isReady: Bool
    var showsReadyBadge = true

    var body: some View {
        HStack(spacing: 28) {
            Circle()
                .fill(Color(.lobbyIcon))
                .frame(width: 82, height: 82)
            Text(name)
                .font(.title2)
                .foregroundStyle(.black)
            Spacer(minLength: 12)
            if showsReadyBadge && isReady {
                Text("Ready")
                    .font(.subheadline)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Color(.lobbyIcon), in: .rect(cornerRadius: 10))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 148, alignment: .leading)
    }
}

// MARK: - "Are you sure?" popup (reusable)

struct ConfirmationPopup: ViewModifier {
    @Binding var isPresented: Bool
    let message: LocalizedStringKey
    let confirmTitle: LocalizedStringKey
    let onConfirm: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
                .allowsHitTesting(!isPresented)

            if isPresented {
                Color.black.opacity(0.25).ignoresSafeArea()

                VStack(spacing: 24) {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 60) {
                        LobbyPillButton(title: "Stay", action: { isPresented = false },
                                        font: .caption, minimumHeight: 32)
                        LobbyPillButton(title: confirmTitle, action: confirm,
                                        font: .caption, minimumHeight: 32, role: .destructive)
                    }
                }
                .padding(24)
                .frame(maxWidth: 280)
                .background(Color(.lobbyCard), in: .rect(cornerRadius: 28))
                .padding(.horizontal, 28)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }

    private func confirm() {
        isPresented = false
        onConfirm()
    }
}

extension View {
    func confirmationPopup(isPresented: Binding<Bool>,
                           message: LocalizedStringKey,
                           confirmTitle: LocalizedStringKey = "Leave",
                           onConfirm: @escaping () -> Void) -> some View {
        modifier(ConfirmationPopup(isPresented: isPresented, message: message,
                                   confirmTitle: confirmTitle, onConfirm: onConfirm))
    }
}
