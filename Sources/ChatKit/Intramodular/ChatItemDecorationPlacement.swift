//
// Copyright (c) Vatsal Manot
//

import SwiftUIZ

public enum ChatItemDecorationPlacement: Hashable {
    case besideItem
}

extension View {
    @ViewBuilder
    public func chatItemDecoration<D: View>(
        placement: ChatItemDecorationPlacement,
        @ViewBuilder decoration: () -> D
    ) -> some View {
        let decoration = decoration().eraseToAnyView()
        
        transformEnvironment(\._chatItemConfiguration) { configuration in
            configuration.decorations[placement] = decoration
        }
    }
}
