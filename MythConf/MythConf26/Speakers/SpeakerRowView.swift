//
//  SpeakerRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row showing a speaker's photo, name, and bio excerpt.
struct SpeakerRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(ViewModel.self) private var viewModel
    let speakerID: String

    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }
    private var speakerSummary: String {
        //:Todo findo out how to split strings
        speaker.speakerInfo.components(separatedBy: "\n\n").first ?? speaker.speakerInfo
    }

    var body: some View {
        HStack(alignment: .top) {
            SpeakerPhotoView(speaker: speaker, size: 56)

            VStack(alignment: .leading) {
                Text(speaker.name)
                    .bold()
                    .foregroundStyle(Color(.label))
                    .accessibilityAddTraits(.isHeader)
                if !speakerSummary.isEmpty {
                    Text(speakerSummary)
                        .font(.body)
                        .foregroundStyle(Color(.label))
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                        .accessibilityLabel("Biography of \(speaker.name). \(speaker.speakerInfo)") //: todo come up with somehting better than Biography
                }
            }
        }
        .padding(.vertical, 4)
        .background(Color(.systemBackground))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("speakers.rowContent.\(speaker.id)")
    }
}

#Preview {
    SpeakerRowView(speakerID: "SarahThornton")
        .environment(ViewModel())
        .padding()
}
