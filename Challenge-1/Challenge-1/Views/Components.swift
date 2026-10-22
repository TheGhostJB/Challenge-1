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
            .background {
                LinearGradient(colors: [Color(hex: 0xD3DEF4), Color(hex: 0xA9B5CF)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }
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
    var backgroundColor: Color? = nil
    var diameter: CGFloat = 44

    var body: some View {
        Button(action: action) { icon }
            .buttonStyle(.plain)
    }

    @ViewBuilder
    private var icon: some View {
        let symbol = Label(title, systemImage: systemImage)
            .labelStyle(.iconOnly)
            .font(.system(size: 20))
            .foregroundStyle(foregroundColor)
            .frame(width: diameter, height: diameter)
            .contentShape(.circle)

        if let backgroundColor {
            symbol.background(backgroundColor, in: .circle)
        } else {
            symbol.glassCircle()
        }
    }
}

struct LobbyPillButton: View {
    let title: LocalizedStringKey
    let action: () -> Void
    var font: Font = .subheadline
    var minimumHeight: CGFloat = 44
    var role: ButtonRole?
    var style: PillStyle = .secondary

    var body: some View {
        Button(role: role, action: action) { content }
            .buttonStyle(.plain)
    }

    @ViewBuilder
    private var content: some View {
        let label = Text(title)
            .font(font)
            .foregroundStyle(style == .secondary ? Color.black : Color.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: minimumHeight)
            .contentShape(.capsule)

        switch style {
        case .primary:
            label.background(Color.brandBlue, in: .capsule)
        case .ready:
            label.background(Color(hex: 0x66C466), in: .capsule)
        case .secondary:
            label.glassCapsule()
        case .dark:
            label.background(Color(hex: 0x1F4260), in: .capsule)
        }
    }
}

// MARK: - Participant row

struct LobbyParticipantRow: View {
    let name: String
    let isReady: Bool
    var showsReadyBadge = true
    var isSearching = false
    var avatarColor: AvatarColor = .gray
    var onEdit: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 16) {
            AvatarView(initials: isSearching ? "" : name.initials, color: avatarColor, size: 82)
            Text(name)
                .font(.title2)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .layoutPriority(1)
            if let onEdit {
                Button("Edit name", systemImage: "pencil", action: onEdit)
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.black)
                    .frame(minWidth: 44, minHeight: 44)
            }
            Spacer(minLength: 12)
            
            if isSearching {
                ProgressView()
            } else if showsReadyBadge {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(isReady ? Color(hex: 0x66C466) : Color.gray.opacity(0.5))
                    .accessibilityLabel(isReady ? "Ready" : "Not ready")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(Color(hex: 0xF3F2F7), in: .rect(cornerRadius: 30))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
    }
}

// MARK: - "Are you sure?" alert

extension View {
    func confirmationPopup(
        isPresented: Binding<Bool>,
        message: LocalizedStringKey,
        confirmTitle: LocalizedStringKey = "Leave",
        onConfirm: @escaping () -> Void
    ) -> some View {
        alert("Are you sure?", isPresented: isPresented) {
            Button("Stay", role: .cancel) { }
            Button(confirmTitle, role: .destructive, action: onConfirm)
        } message: {
            Text(message)
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
    
    static let brandBlue = Color(hex: 0x4189C3)
}

struct DifficultyTheme {
    let top: Color
    let bottom: Color
    let text: Color

    var gradient: LinearGradient {
        LinearGradient(colors: [top, bottom], startPoint: .top, endPoint: .bottom)
    }
}

extension GameDifficulty {
    var theme: DifficultyTheme {
        switch self {
        case .easy:
            DifficultyTheme(top: Color(hex: 0xFCF2DD), bottom: Color(hex: 0xE6DAC0), text: Color(hex: 0x12304A))
        case .medium:
            DifficultyTheme(top: .brandBlue, bottom: Color(hex: 0x1F4260), text: Color(hex: 0xFBF0DA))
        case .hard:
            DifficultyTheme(top: Color(hex: 0xAE2C24), bottom: Color(hex: 0x7A1913), text: Color(hex: 0xFBF0DA))
        }
    }
}

extension View {
    func cardField(tint: Color) -> some View {
        self
            .background(tint.opacity(0.1), in: .capsule)
            .overlay { Capsule().strokeBorder(tint.opacity(0.25), lineWidth: 1) }
    }
}

struct OptionStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack(spacing: 16) {
            Button("Fewer", systemImage: "minus") { value -= 1 }
                .disabled(value <= range.lowerBound)

            Text("\(value)")
                .font(.body.monospacedDigit())
                .frame(minWidth: 28)

            Button("More", systemImage: "plus") { value += 1 }
                .disabled(value >= range.upperBound)
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
        .font(.title3)
    }
}

extension View {
    @ViewBuilder
    func glassCapsule() -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular, in: .capsule)
        } else {
            self.background(.ultraThinMaterial, in: .capsule)
        }
    }
}

enum PillStyle {
    case primary, secondary, ready, dark
}

extension View {
    @ViewBuilder
    func glassCircle() -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular, in: .circle)
        } else {
            self.background(.ultraThinMaterial, in: .circle)
        }
    }
}

enum AvatarColor: Int, CaseIterable, Identifiable {
    case gray, blue, red, green, orange, purple

    var id: Int { rawValue }

    var color: Color {
        switch self {
        case .gray:   Color(hex: 0xA3A3A8)
        case .blue:   Color(hex: 0x3B86C7)
        case .red:    Color(hex: 0xAE2C24)
        case .green:  Color(hex: 0x66C466)
        case .orange: Color(hex: 0xE8913A)
        case .purple: Color(hex: 0x8A6FD1)
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .gray:   "Gray"
        case .blue:   "Blue"
        case .red:    "Red"
        case .green:  "Green"
        case .orange: "Orange"
        case .purple: "Purple"
        }
    }
    
    var menuIcon: Image {
        let symbol = UIImage(systemName: "circle.fill") ?? UIImage()
        let tinted = symbol.withTintColor(UIColor(color), renderingMode: .alwaysOriginal)
        return Image(uiImage: tinted)
    }
}

extension String {
    var initials: String {
        let letters = split(separator: " ").prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}

struct AvatarView: View {
    let initials: String
    let color: AvatarColor
    var size: CGFloat = 64

    var body: some View {
        Circle()
            .fill(color.color)
            .frame(width: size, height: size)
            .overlay {
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundStyle(.white)
            }
    }
}
