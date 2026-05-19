//
//  MyScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

struct MyScheduleView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(ViewModel.self) private var viewModel
    @Binding var selectedTab: Int
    @State private var isShowingSettings = false
    @AccessibilityFocusState private var isSettingsButtonFocused: Bool
    @Namespace private var scheduleRotorNamespace

    private var headerBackground: AnyShapeStyle {
        reduceTransparency ? AnyShapeStyle(Color(.systemBackground)) : AnyShapeStyle(.regularMaterial)
    }

    private var visibleFavouriteSessions: [Session] {
        viewModel.favouritesBySession.flatMap { $0 }.filter { $0.sessionType != .dummy }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favouriteIds.isEmpty {
                    ScrollView {
                        VStack(spacing: 24) {
                            ContentUnavailableView(
                                "No Favourites Yet",
                                systemImage: "star",
                                description: Text("Tap the star on any session in the Programme to add it to your schedule.")
                            )
                            .accessibilityIdentifier("mySchedule.empty")

                            Button {
                                selectedTab = 0
                            } label: {
                                Label("Browse Programme", systemImage: "calendar")
                                    .frame(minHeight: 44)
                                    .accessibilityIdentifier("mySchedule.browseProgramme")
                            }
                            .buttonStyle(.borderedProminent)
                            .accessibilityHint("Opens the Programme tab so you can find sessions to add to your schedule.")
                        }
                    }.defaultScrollAnchor(.center, for: .alignment)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            ForEach(viewModel.favouritesBySession.indices, id: \.self) { dayIndex in
                                let daySessions = viewModel.favouritesBySession[dayIndex]
                                if daySessions.first?.sessionType != .dummy {
                                    Section {
                                        ForEach(daySessions) { session in
                                            ParallelSessionsRowView(
                                                session: session,
                                                daySessions: daySessions,
                                                rotorNamespace: scheduleRotorNamespace
                                            )
                                            Divider()
                                        }
                                    } header: {
                                        Text(dayHeader(for: daySessions))
                                            .font(.headline)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(headerBackground)
                                            .accessibilityAddTraits(.isHeader)
                                    }
                                }
                            }
                        }
                    }
                    .accessibilityIdentifier("mySchedule.schedule")
                    .accessibilityElement(children: .contain)
                    .scheduleAccessibilityRotors(
                        entries: scheduleRotorEntries,
                        namespace: scheduleRotorNamespace
                    )
                }
            }
            .navigationTitle("My Schedule")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SettingsToolbarButton {
                        isShowingSettings = true
                    }
                    .accessibilityFocused($isSettingsButtonFocused)
                }
            }
            .sheet(isPresented: $isShowingSettings, onDismiss: restoreSettingsButtonFocus) {
                SettingsView()
            }
            .conferenceNavigationDestinations()
        }
    }

    private func restoreSettingsButtonFocus() {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            isSettingsButtonFocused = true
        }
    }

    private func dayHeader(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    private var scheduleRotorEntries: [ScheduleRotorCategory: [ScheduleRotorEntry]] {
        [
            .liveSessions: ScheduleRotorEntries.liveEntries(in: visibleFavouriteSessions, viewModel: viewModel),
            .breaks: ScheduleRotorEntries.breakEntries(in: visibleFavouriteSessions)
        ]
    }
}

#Preview {
    MyScheduleView(selectedTab: .constant(3))
        .environment(ViewModel())
}
