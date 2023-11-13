//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

@_spi(Internal)
public struct DefaultChatViewBackground: View {
    public var body: some View {
        #if os(iOS)
        Color.systemBackground
        #else
        Color.secondarySystemBackground
        #endif
    }
    
    public init() {
        
    }
}
