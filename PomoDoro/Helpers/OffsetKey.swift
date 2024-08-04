//
//  OffsetKey.swift
//  PomoDoro
//
//  Created by Grégory Corin on 14/07/2024.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
