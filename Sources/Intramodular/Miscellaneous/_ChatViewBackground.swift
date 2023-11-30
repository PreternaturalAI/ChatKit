//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

@_spi(Internal)
public struct _ChatViewBackground: View {
    public var body: some View {
        #if os(iOS) || os(tvOS)
        Color.systemBackground
        #elseif os(macOS)
        Color.secondarySystemBackground
        #elseif os(visionOS)
        Color.clear
        #else
        _UnimplementedView()
        #endif
    }
    
    public init() {
        
    }
}
