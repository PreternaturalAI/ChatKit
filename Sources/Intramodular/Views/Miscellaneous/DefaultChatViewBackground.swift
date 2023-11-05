//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

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
