//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX

public enum MessageDeliveryState: Hashable {
    case sending
    case errored
    case idle
}
