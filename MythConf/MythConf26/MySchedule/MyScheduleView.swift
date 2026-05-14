//
//  MyScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

struct MyScheduleView: View {
    @Environment(ViewModel.self) private var viewModel
    /// Pinned section headers sit on top of scrolling content. When the
    /// user has Increase Contrast on we swap the header background from
    /// `.regularMaterial` to `.thickMaterial` so the day label remains
    /// clearly readable rather than tinted by whatever is sliding past
    /// underneath.
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favouriteIds.isEmpty {
                    ContentUnavailableView(
                        "No Favourites Yet",
                        systemImage: "star",
                        description: Text("Tap the star on any session in the Programme to save it here.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            // Re-evaluate Up Next every minute so the
                            // promoted session rolls over as time passes
                            // without any manual refresh.
                            TimelineView(.everyMinute) { context in
                                if let session = viewModel.nextUpcomingFavouriteSession(now: context.date) {
                                    UpNextCardView(session: session, now: context.date)
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                }
                            }

                            ForEach(viewModel.favouritesBySession.indices, id: \.self) { dayIndex in
                                let daySessions = viewModel.favouritesBySession[dayIndex]
                                if daySessions.first?.sessionType != .dummy {
                                    Section {
                                        FavouriteDaySessionList(sessions: daySessions)
                                    } header: {
                                        Text(dayHeader(for: daySessions))
                                            .font(.headline)
                                            .bold()
                                            .foregroundStyle(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            // Materials are always translucent, so even
                                            // `.thickMaterial` lets enough of the scrolling
                                            // content through to fail Inspector's contrast
                                            // check. When Increase Contrast is on, fall back
                                            // to a fully opaque system background so the
                                            // day label sits on a guaranteed-contrast surface.
                                            .background(contrast == .increased ? AnyShapeStyle(Color(.systemBackground)) : AnyShapeStyle(.regularMaterial))
                                            .accessibilityAddTraits(.isHeader)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Schedule")
            .conferenceNavigationDestinations()
        }
    }

    private func dayHeader(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }
}

/// Renders the parallel-session rows for a single day. Extracted into its
/// own `View` so its `body` is unambiguously evaluated in SwiftUI's
/// `ViewBuilder` context — inlining the ForEach inside `Section { ... }`
/// caused Xcode 16 to resolve it to `MapContentBuilder`.
private struct FavouriteDaySessionList: View {
    let sessions: [Session]

    var body: some View {
        ForEach(sessions) { session in
            ParallelSessionsRowView(session: session)
            Divider()
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    MyScheduleView()
        .environment(ViewModel())
}
