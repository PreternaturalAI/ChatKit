//
// Copyright (c) Vatsal Manot
//

import Swift

public struct AnyChatItemIdentifier: Hashable {
    public let base: AnyHashable
    
    public init(base: AnyHashable) {
        self.base = base
    }
}
