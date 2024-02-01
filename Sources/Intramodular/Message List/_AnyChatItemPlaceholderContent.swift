//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct _AnyChatItemPlaceholderContent: View {
    @Environment(\.userInterfaceIdiom) var userInterfaceIdiom
    
    let phase: ChatItemActivityPhase
    
    public var body: some View {
        LazyAppearView {
            ProgressView()
                .controlSize(userInterfaceIdiom == .vision ? .regular : .mini)
                .padding(.extraSmall)
                .transition(.identity.animation(.default))
        }
    }
    
    public init(
        phase: ChatItemActivityPhase = .sending
    ) {
        self.phase = phase
    }
}
