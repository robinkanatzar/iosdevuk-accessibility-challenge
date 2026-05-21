//
//  TimeColumnView.swift
//  IOSDevuk26
//

import SwiftUI

/// A fixed-width column showing a session's start and end times.
struct TimeColumnView: View {
    @Environment(ViewModel.self) private var viewModel
    let startTime: String
    let endTime: String

    var body: some View {
        VStack(alignment: .trailing) {
            Text(startTime)
                .bold()
                .monospacedDigit()
            Text(endTime)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .appFont(.caption, useLexend: viewModel.useLexendFont)
        .frame(minWidth: 44, alignment: .trailing)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session start time \(startTime), session end time \(endTime)")
    }
}
