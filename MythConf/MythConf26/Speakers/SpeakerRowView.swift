//
//  SpeakerRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A row showing a speaker's photo, name, and bio excerpt.
struct SpeakerRowView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let speakerID: String
    
    private var speaker: Speaker { viewModel.speakerFrom(speakerID: speakerID) }
    
    var body: some View {
        
        Group {
            
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    SpeakerPhotoView(speaker: speaker, size: 80)
                    textBlock
                }
            } else {
                HStack(alignment: .top) {
                    SpeakerPhotoView(speaker: speaker, size: 56)
                    textBlock
                }
            }
        }
 
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view speaker details and sessions")
    }
    
    private var textBlock: some View {
        VStack(alignment: .leading) {
            Text(speaker.name)
                .bold()
            if !speaker.speakerInfo.isEmpty {
                Text(speaker.speakerInfo)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
    
    private var accessibilityLabel: String {
        if speaker.speakerInfo.isEmpty {
            return speaker.name
        }
        return "\(speaker.name). \(speaker.speakerInfo)"
    }
}
