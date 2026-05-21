//
//  MyScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

struct MyScheduleView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.locale) private var locale
    /// Owned by `HomeView` so the navigation stack survives the rotation-
    /// triggered TabView rebuild (`.id(verticalSizeClass)`).
    @Binding var navigationPath: NavigationPath

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.favouriteIds.isEmpty {
                    ContentUnavailableView {
                        Label {
                            Text("No Favourites Yet")
                        } icon: {
                            Image(systemName: "star")
                                .secondaryTextStyle()
                        }
                    } description: {
                        Text("Tap the star on any session in the Programme to save it here.")
                            .secondaryTextStyle()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            ForEach(viewModel.favouritesBySession.indices, id: \.self) { dayIndex in
                                let daySessions = viewModel.favouritesBySession[dayIndex]
                                if daySessions.first?.sessionType != .dummy {
                                    Section {
                                        ForEach(daySessions) { session in
                                            ParallelSessionsRowView(session: session)
                                            Divider()
                                        }
                                    } header: {
                                        Text(dayHeader(for: daySessions))
                                            .font(.headline)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(.ultraThinMaterial)
                                            .accessibilityAddTraits(.isHeader)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .conferenceNavigationDestinations()
            .languageToggleToolbar()
            .navigationTitle("My Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        }
    }

    private func dayHeader(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(locale))
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    MyScheduleView(navigationPath: $path)
        .environment(ViewModel())
}
