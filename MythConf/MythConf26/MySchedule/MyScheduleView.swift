//
//  MyScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

struct MyScheduleView: View {
    @Environment(ViewModel.self) private var viewModel

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
                            ForEach(viewModel.favouritesBySession.indices, id: \.self) { dayIndex in
                                let daySessions = viewModel.favouritesBySession[dayIndex]
                                if daySessions.first?.sessionType != .dummy {
                                    Section {
                                        ForEach(daySessions) { session in
                                            ParallelSessionsRowView(session: session)
                                            Divider()
                                                .accessibilityHidden(true)
                                        }
                                    } header: {
                                        Text(dayHeader(for: daySessions))
                                            .accessibilityAddTraits(.isHeader)
                                            .font(.headline)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(.regularMaterial)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Schedule")
            .toolbarBackground(.background, for: .navigationBar)
            .conferenceNavigationDestinations()
        }
    }

    private func dayHeader(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }
}

// MARK: - Preview

#Preview {
    let viewModel: ViewModel = {
        let vm = ViewModel()
        vm.favouriteIds = []
        return vm
    }()
    MyScheduleView()
        .environment(viewModel)
}

#Preview("With favourites") {
    let viewModel: ViewModel = {
        let vm = ViewModel()
        vm.favouriteIds = Array(vm.confData.talks.prefix(3).map(\.id))
        vm.saveFavourites()
        vm.loadFavourites()
        return vm
    }()
    MyScheduleView()
        .environment(viewModel)
}
