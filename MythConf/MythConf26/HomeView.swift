//
//  HomeView.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI

//struct HomeView: View {
//    @Environment(ViewModel.self) private var viewModel
//
//    var body: some View {
//            TabView {
//                ProgrammeView()
//                    .accessibilityIdentifier("tab.programme")
//                    .tabItem {
//                        Label("Programme", systemImage: "calendar")
//                            .symbolRenderingMode(.monochrome)
//                    }
//
//                SpeakersView()
//                    .accessibilityIdentifier("tab.speakers")
//                    .tabItem {
//                        Label("Speakers", systemImage: "person.2")
//                            .symbolRenderingMode(.monochrome)
//                    }
//
//                LocationsView()
//                    .accessibilityIdentifier("tab.locations")
//                    .tabItem {
//                        Label("Locations", systemImage: "map")
//                            .symbolRenderingMode(.monochrome)
//                    }
//
//                MyScheduleView()
//                    .accessibilityIdentifier("tab.mySchedule")
//                    .tabItem {
//                        Label("My Schedule", systemImage: "star")
//                            .symbolRenderingMode(.monochrome)
//                    }
//            }
//    }
//
//}

struct HomeView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ProgrammeView()
                .tag(0)
                .accessibilityIdentifier("tab.programme")
                .tabItem {
                    Label("Programme", systemImage: "calendar")
                        .symbolRenderingMode(.monochrome)
                }

            SpeakersView()
                .tag(1)
                .accessibilityIdentifier("tab.speakers")
                .tabItem {
                    Label("Speakers", systemImage: "person.2")
                        .symbolRenderingMode(.monochrome)
                }

            LocationsView()
                .tag(2)
                .accessibilityIdentifier("tab.locations")
                .tabItem {
                    Label("Locations", systemImage: "map")
                        .symbolRenderingMode(.monochrome)
                }

            MyScheduleView()
                .tag(3)
                .accessibilityIdentifier("tab.mySchedule")
                .tabItem {
                    Label("My Schedule", systemImage: "star")
                        .symbolRenderingMode(.monochrome)
                }
        }.onOpenURL { url in
            print("🔗 [DeepLink] onOpenURL fired with: \(url.absoluteString)")
            print("🔗 [DeepLink] scheme: '\(url.scheme ?? "nil")'  host: '\(url.host() ?? "nil")'  pathComponents: \(url.pathComponents)")

            guard url.scheme == "MythConf26" else {
                print("🔗 [DeepLink] ❌ Scheme mismatch — got '\(url.scheme ?? "nil")', expected 'mythconf26'")
                return
            }
            guard url.host() == "talk" else {
                print("🔗 [DeepLink] ❌ Host mismatch — got '\(url.host() ?? "nil")', expected 'talk'")
                return
            }
            guard let uuidString = url.pathComponents.last else {
                print("🔗 [DeepLink] ❌ No path component found")
                return
            }
            guard let talkID = UUID(uuidString: uuidString) else {
                print("🔗 [DeepLink] ❌ Could not parse UUID from: '\(uuidString)'")
                return
            }

            print("🔗 [DeepLink] ✅ Parsed talkID: \(talkID) — switching to Programme tab")
            selectedTab = 0
            viewModel.pendingDeepLinkTalkID = talkID
            print("🔗 [DeepLink] pendingDeepLinkTalkID set to: \(talkID)")
        }
    }
}

#Preview {
    HomeView()
        .environment(ViewModel())
}
