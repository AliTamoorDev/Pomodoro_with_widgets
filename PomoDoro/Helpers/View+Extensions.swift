//
//  View+Extensions.swift
//  PomoDoro
//
//  Created by Grégory Corin on 14/07/2024.
//

import SwiftUI

/// Custom View Extensions

extension View {
    /// Custom spacers
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity,  alignment: alignment)
    }
    
    /// Checking Two Dates are same
    func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}
