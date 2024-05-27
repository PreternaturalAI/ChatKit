//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX
import SwiftUI
public enum ChatItemActivityPhase: Hashable {
    case idle
    case sending
    case failed(AnyError)
    
    public static func failed(_ error: Swift.Error) -> Self {
        Self.failed(AnyError(erasing: error))
    }
}
