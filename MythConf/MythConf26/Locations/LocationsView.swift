//
//  LocationsView.swift
//  IOSDevuk26
//

import SwiftUI

struct LocationsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(ViewModel.self) private var viewModel
    @State private var isShowingSettings = false
    @AccessibilityFocusState private var isSettingsButtonFocused: Bool

    var body: some View {
        NavigationStack {
            List(viewModel.confData.locations) { location in
                NavigationLink(value: LocationNavigationID(value: location.id)) {
                    VStack(alignment: .leading) {
                        Text(location.name)
                            .dyslexiaReadingFont(.body, size: 17, weight: .bold)
                        if  !dynamicTypeSize.isAccessibilitySize {
                            Text(location.placeDescription)
                                .dyslexiaReadingFont(.body, size: 17)
                                .foregroundStyle(.secondary)
                                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
                .accessibilityIdentifier("locations.row.\(location.id)")
            }
            .accessibilityIdentifier("locations.list")
            .navigationTitle("Locations")
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
}

#Preview {
    LocationsView()
        .environment(ViewModel())
}
