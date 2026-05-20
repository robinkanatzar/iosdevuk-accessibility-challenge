//
//  SpeakerRowView.swift
//  IOSDevuk26
//

import SwiftUI
import NaturalLanguage


/// A row showing a speaker's photo, name, and bio excerpt.
struct SpeakerRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(ViewModel.self) private var viewModel
    let speakerID: String

    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }

    private var speakerSummary: String {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = speaker.speakerInfo

        if let firstSentenceRange = tokenizer.tokens(for: speaker.speakerInfo.startIndex..<speaker.speakerInfo.endIndex).first {
            return String(speaker.speakerInfo[firstSentenceRange])
        }

        return speaker.speakerInfo
    }

    var body: some View {
        Group {
            if dynamicTypeSize > .large {
                VStack(alignment: .leading, spacing: 8) {
                    SpeakerPhotoView(speaker: speaker, size: 56)
                    speakerContent
                }
            } else {
                HStack(alignment: .top, spacing: 12) {
                    SpeakerPhotoView(speaker: speaker, size: 56)
                    speakerContent
                }
            }
        }
        .padding(.vertical, 4)
        .background(Color(.systemBackground))
        .accessibilityIdentifier("speakers.rowContent.\(speaker.id)")
    }

    @ViewBuilder
    private var speakerContent: some View {
        VStack(alignment: .leading) {
            Text(speaker.name)
                .dyslexiaReadingFont(.body, size: 17, weight: .bold)
                .foregroundStyle(Color(.label))

//            if !speakerSummary.isEmpty && !dynamicTypeSize.isAccessibilitySize {
            if !speakerSummary.isEmpty {
                Text(speakerSummary)
                    .dyslexiaReadingFont(.body, size: 17)
                    .foregroundStyle(.secondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
            }
        }
    }
}

#Preview {
    SpeakerRowView(speakerID: "SarahThornton")
        .environment(ViewModel())
        .padding()
}
