// WubbaLubbaDubDubTV/Features/Components/SkeletonRow.swift
import SwiftUI

struct SkeletonRow: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 5).fill(.secondary.opacity(0.2))
                .frame(width: 44, height: 44)
                .redacted(reason: .placeholder)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 3).fill(.secondary.opacity(0.2)).frame(height: 12)
                RoundedRectangle(cornerRadius: 3).fill(.secondary.opacity(0.2)).frame(height: 12).opacity(0.8)
            }
        }
        .accessibilityHidden(true)
    }
}
