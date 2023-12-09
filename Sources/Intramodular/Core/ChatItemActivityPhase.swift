//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX

public enum ChatItemActivityPhase: Hashable {
    case idle
    case sending
    case errored
}
