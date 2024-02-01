//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct _AnyChatItemPlaceholderContent: View {
    let phase: ChatItemActivityPhase
    
    public var body: some View {
        ProgressView()
            .controlSize(.small)
            .padding(.leading, .extraSmall)
    }
    
    public init(
        phase: ChatItemActivityPhase = .sending
    ) {
        self.phase = phase
    }
}
