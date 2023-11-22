//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

public struct _ChatMessageListItemAttributes: Hashable, Sendable {
    public let isSender: Bool
    
    public init(isSender: Bool) {
        self.isSender = isSender
    }
}
