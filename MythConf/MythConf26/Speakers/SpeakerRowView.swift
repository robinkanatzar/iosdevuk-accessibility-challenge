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
            print("Franklin")
            return String(speaker.speakerInfo[firstSentenceRange])
        }

        print("Jranklin")
        return speaker.speakerInfo
    }

    var body: some View {
        HStack(alignment: .top) {
            SpeakerPhotoView(speaker: speaker, size: 56)

            VStack(alignment: .leading) {
                Text(speaker.name)
                    .bold()
                    .foregroundStyle(Color(.label))
                if !speakerSummary.isEmpty {
                    Text(speakerSummary)
                        .font(.body)
                        .foregroundStyle(Color(.label))
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                        .accessibilityLabel("About \(speaker.name). \(speakerSummary)")
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
