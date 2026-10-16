//
//  HostModalView.swift
//  Challenge-1
//
//  Created by Giuseppe Di Donna on 16/10/2026.
//


import SwiftUI

struct HostModalView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("This is the modal")
                .font(.title)

            Button("Close") {
                dismiss()
            }
        }
        .padding()
    }
}


#Preview {
    HostModalView()
}
