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
                            .foregroundStyle(Color(.label))
                        Text(location.placeDescription)
                            .dyslexiaReadingFont(.body, size: 17)
                            .foregroundStyle(Color(.label))
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                    }
                }
                // Accessibility: setting a label directly on the NavigationLink collapses the
                // entire row — name and description — into a single focusable element whose
                // announcement is just the location's name. This keeps VoiceOver list traversal
                // fast and predictable; the full description is available once the user navigates
                // into the detail view. It also makes Voice Control commands unambiguous: users say
                // "tap Tyndall Lecture Theatre" rather than a long description-derived phrase.
                // Note: this label overrides any accessibilityElement(children:) modifier on
                // the VStack, so that modifier is intentionally absent from the row.
                .accessibilityLabel(location.name)
                .accessibilityInputLabels([
                    location.name,
                    "Open \(location.name)"
                ])
                .accessibilityIdentifier("locations.row.\(location.id)")
                .listRowBackground(Color(.systemBackground)) 
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
