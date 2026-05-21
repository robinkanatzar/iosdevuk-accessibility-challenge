//
//  View+Ext.swift
//  MythConf26
//
//  Created by Steven Hill on 13/05/2026.
//

import SwiftUI

extension View {
    @ViewBuilder
    func adaptivePickerStyle(isAccessibilitySize: Bool) -> some View {
        if isAccessibilitySize {
            self.pickerStyle(.navigationLink)
        } else {
            self.pickerStyle(.segmented)
        }
    }
}
