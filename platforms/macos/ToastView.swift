//
//  ToastView.swift
//  GoNhanh
//
//  Toast notification view for language toggle
//

import SwiftUI

@available(macOS 13.0, *)
struct ToastView: View {
    let isVietnamese: Bool

    var body: some View {
        HStack(spacing: 20) {
            Text(isVietnamese ? "🇻🇳" : "🇬🇧")
                .font(.system(size: 48))

            Text(isVietnamese ? "Tiếng Việt" : "English")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 32)
        .fixedSize()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// Fallback for macOS 12
struct ToastViewLegacy: View {
    let isVietnamese: Bool

    var body: some View {
        HStack(spacing: 20) {
            Text(isVietnamese ? "🇻🇳" : "🇬🇧")
                .font(.system(size: 48))

            Text(isVietnamese ? "Tiếng Việt" : "English")
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(.primary)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 32)
        .fixedSize()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.95))
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    if #available(macOS 13.0, *) {
        VStack(spacing: 20) {
            ToastView(isVietnamese: true)
            ToastView(isVietnamese: false)
        }
        .padding(40)
        .background(Color.gray.opacity(0.3))
    }
}
