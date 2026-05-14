//
//  SessionStatusBadge.swift
//  MythConf26
//
//  Created by Byaruhanga Franklin on 14/05/2026.
//


import SwiftUI

struct SessionStatusBadge: View {
    let session: Session

    private var tint: Color {
        switch session.liveStatus {
        case .live:
            return .red
        case .upcoming:
            return .orange
        case .ended:
            return .secondary
        }
    }

    var body: some View {
//        if session.liveStatus == .upcoming {
//            EmptyView()
//        } else {
            Label {
                Text(session.liveStatus.title)
            } icon: {
                Image(systemName: session.liveStatus.symbolName)
                    .accessibilityHidden(true)
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(tint.opacity(0.12))
            )
            .accessibilityLabel(session.liveStatus.title)
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
//        }
    }
}
