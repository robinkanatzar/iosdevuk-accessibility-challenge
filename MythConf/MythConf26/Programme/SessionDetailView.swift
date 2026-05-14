//
//  SessionDetailView.swift
//  IOSDevuk26
//

import SwiftUI
import NaturalLanguage

struct SessionDetailView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(ViewModel.self) private var viewModel
    let talkReference: TalkReference

    private var talk: Talk { viewModel.talkFrom(talkID: talkReference.talkID) }
    private var session: Session { talkReference.session }
    private var isFavourite: Bool { viewModel.isFavourite(talk: talk) }
    private var locationName: String { viewModel.locationNameFrom(locationID: talk.locationID) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text(talk.talkTitle)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("sessionDetail.title")

                VStack(alignment: .leading, spacing: 20) {
                    sessionInfoRow(
                        title: "Time",
                        value: session.timeRange,
                        systemImage: "clock",
                        accessibilityIdentifier: "sessionDetail.time"
                    )

                    NavigationLink(value: LocationNavigationID(value: talk.locationID)) {
                        sessionInfoRowContent(
                            title: "Location",
                            value: locationName,
                            systemImage: "mappin.circle"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Location")
                    .accessibilityValue(locationName)
                    .accessibilityIdentifier("sessionDetail.location")
                }

                speakerSection

                VStack(alignment: .leading, spacing: 14) {
                    sectionHeading("About This Session")
                        .accessibilityIdentifier("sessionDetail.aboutHeading")

                    Text(talk.talkDescription)
                        .font(.body)
                        .lineSpacing(5)
                        .foregroundStyle(Color(.label))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("sessionDetail.about")
                }

//                Button {
//                    toggleFavourite()
//                } label: {
//                    Label(scheduleActionTitle, systemImage: isFavourite ? "checkmark" : "plus")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 16)
//                }
                Button {
                    toggleFavourite()
                } label: {
                    Group {
                        if dynamicTypeSize.isAccessibilitySize {
                            Text(scheduleActionTitle)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        } else {
                            Label(scheduleActionTitle, systemImage: isFavourite ? "checkmark" : "plus")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel(scheduleActionAccessibilityLabel)
                .accessibilityValue(isFavourite ? "In My Schedule" : "Not in My Schedule")
                .accessibilityHint(isFavourite ? "Removes this session from My Schedule" : "Adds this session to My Schedule")
                .accessibilityInputLabels([scheduleActionTitle, talk.talkTitle])
                .accessibilityIdentifier("sessionDetail.scheduleAction")
            }
            .padding(.horizontal)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .accessibilityAction(.magicTap) {
            toggleFavourite()
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            SaveSessionTip.hasViewedSaveContext = true
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavouriteButtonView(talk: talk)
            }
        }
    }

    private var speakerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(talk.speakerIDs.count == 1 ? "Speaker" : "Speakers")

            ForEach(talk.speakerIDs, id: \.self) { speakerID in
                NavigationLink(value: SpeakerNavigationID(value: speakerID)) {
                    speakerCard(speakerID: speakerID)
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(viewModel.speakerNameFrom(speakerID: speakerID))
                .accessibilityValue(speakerSummary(for: speakerID))
                .accessibilityIdentifier("sessionDetail.speaker.\(speakerID)")
            }
        }
    }

    private var scheduleActionTitle: String {
        isFavourite ? "Remove from Schedule" : "Add to Schedule"
    }

    private var scheduleActionAccessibilityLabel: String {
        isFavourite ? "Remove \(talk.talkTitle) from your schedule" : "Add \(talk.talkTitle) to your schedule"
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.secondary)
            .tracking(1.2)
            .accessibilityLabel(title)
            .accessibilityAddTraits(.isHeader)
    }

    private func sessionInfoRow(
        title: String,
        value: String,
        systemImage: String,
        accessibilityIdentifier: String
    ) -> some View {
        sessionInfoRowContent(title: title, value: value, systemImage: systemImage)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(value)
            .accessibilityIdentifier(accessibilityIdentifier)
    }

    private func sessionInfoRowContent(title: String, value: String, systemImage: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.tint)
                .frame(width: 52, height: 52)
                .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .accessibilityAddTraits(.isHeader)

                Text(value)
                    .font(.body)
                    .foregroundStyle(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func speakerCard(speakerID: String) -> some View {
        let speaker = viewModel.speakerFrom(speakerID: speakerID)

        @ViewBuilder
        var speakerDetails: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(speaker.name)
                    .font(.body)
                    .foregroundStyle(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)

                Text(speakerSummary(for: speakerID))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                    .fixedSize(horizontal: false, vertical: true)
            }.fixedSize(horizontal: false, vertical: true)
        }

        var infoIcon: some View {
            Image(systemName: "info.circle")
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.08), in: Circle())
                .accessibilityHidden(true)
        }

        return Group {
            if dynamicTypeSize > .large {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        SpeakerPhotoView(
                            speaker: speaker,
                            size: dynamicTypeSize.isAccessibilitySize ? 48 : 64
                        )
                        Spacer()
                        infoIcon
                    }
                    speakerDetails
                }
            } else {
                HStack(alignment: .center, spacing: 14) {
                    SpeakerPhotoView(
                        speaker: speaker,
                        size: dynamicTypeSize.isAccessibilitySize ? 48 : 64
                    )

                    speakerDetails

                    Spacer(minLength: 8)

                    infoIcon
                }
            }
        }
        .padding(dynamicTypeSize.isAccessibilitySize ? 12 : 14)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
        .contentShape(RoundedRectangle(cornerRadius: 18))
    }

    private func speakerSummary(for speakerID: String) -> String {
        let speaker = viewModel.speakerFrom(speakerID: speakerID)
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = speaker.speakerInfo

        if let firstSentenceRange = tokenizer.tokens(for: speaker.speakerInfo.startIndex..<speaker.speakerInfo.endIndex).first {
            return String(speaker.speakerInfo[firstSentenceRange])
        }

        print("Jranklin")
        return speaker.speakerInfo
    }

    private func toggleFavourite() {
        if isFavourite {
            viewModel.removeFavourite(talk: talk)
            FavouriteToggleFeedback.removed()
        } else {
            viewModel.addFavourite(talk: talk)
            SaveSessionTip.hasSavedFavourite = true
            FavouriteToggleFeedback.added()
        }
    }
}

#Preview {
    let viewModel = ViewModel()
    let talkID = UUID(uuidString: "C1001006-C100-4100-8100-100000000006")!
    let session = viewModel.confData.sessions[1][2]
    
    NavigationStack {
        SessionDetailView(talkReference: TalkReference(talkID: talkID, session: session))
            .environment(viewModel)
    }
}
