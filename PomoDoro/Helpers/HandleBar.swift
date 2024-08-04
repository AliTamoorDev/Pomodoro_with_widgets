//
//  HandleBar.swift
//  PomoDoro
//
//  Created by Grégory Corin on 19/07/2024.
//

import SwiftUI

struct HandleBar: View {
    var body: some View {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary)
                .frame(width: 40, height: 5)
                .padding(.top, 8)
        }
}

#Preview {
    HandleBar()
}
