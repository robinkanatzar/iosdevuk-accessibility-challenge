//
//  MythConfTips.swift
//  MythConf26
//

import SwiftUI
import TipKit

struct SaveSessionTip: Tip {
    @Parameter
    static var hasViewedSaveContext: Bool = false

    @Parameter
    static var hasSavedFavourite: Bool = false

    var title: Text {
        Text("Save Sessions")
    }

    var message: Text? {
        Text("Tap the star to keep sessions in My Schedule.")
    }

    var image: Image? {
        Image(systemName: "star")
    }

    var rules: [Rule] {
        #Rule(Self.$hasViewedSaveContext) { $0 == true }
        #Rule(Self.$hasSavedFavourite) { $0 == false }
    }

    var options: [TipOption] {
        MaxDisplayCount(2)
    }
}

struct ConferenceDayPickerTip: Tip {
    @Parameter
    static var hasViewedProgramme: Bool = false

    @Parameter
    static var hasMultipleConferenceDays: Bool = false

    @Parameter
    static var hasChangedProgrammeDay: Bool = false

    var title: Text {
        Text("Switch Days")
    }

    var message: Text? {
        Text("Use these tabs to browse each conference day.")
    }

    var image: Image? {
        Image(systemName: "calendar")
    }

    var rules: [Rule] {
        #Rule(Self.$hasViewedProgramme) { $0 == true }
        #Rule(Self.$hasMultipleConferenceDays) { $0 == true }
        #Rule(Self.$hasChangedProgrammeDay) { $0 == false }
    }

    var options: [TipOption] {
        MaxDisplayCount(1)
    }
}

struct SpeakerSearchTip: Tip {
    @Parameter
    static var hasViewedSpeakers: Bool = false

    @Parameter
    static var hasSearchedSpeakers: Bool = false

    var title: Text {
        Text("Find a Speaker")
    }

    var message: Text? {
        Text("Search by name to jump straight to a speaker profile.")
    }

    var image: Image? {
        Image(systemName: "magnifyingglass")
    }

    var rules: [Rule] {
        #Rule(Self.$hasViewedSpeakers) { $0 == true }
        #Rule(Self.$hasSearchedSpeakers) { $0 == false }
    }

    var options: [TipOption] {
        MaxDisplayCount(2)
    }
}

struct OpenInMapsTip: Tip {
    @Parameter
    static var hasViewedLocationDetail: Bool = false

    @Parameter
    static var hasOpenedMaps: Bool = false

    var title: Text {
        Text("Open in Maps")
    }

    var message: Text? {
        Text("Open this venue in Maps for directions around campus.")
    }

    var image: Image? {
        Image(systemName: "map")
    }

    var rules: [Rule] {
        #Rule(Self.$hasViewedLocationDetail) { $0 == true }
        #Rule(Self.$hasOpenedMaps) { $0 == false }
    }

    var options: [TipOption] {
        MaxDisplayCount(1)
    }
}
