//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swift

public struct AnyChatItemIdentifier: Hashable {
    public var base: AnyHashable
    
    public init(base: AnyHashable) {
        self.base = base
    }
}

// MARK: - Conformances

extension AnyChatItemIdentifier: Codable {
    public init(
        from decoder: Decoder
    ) throws {
        self.init(base: try _UnsafelySerialized<AnyHashable>(from: decoder).wrappedValue)
    }
    
    public func encode(
        to encoder: Encoder
    ) throws {
        try _UnsafelySerialized<AnyHashable>(base).encode(to: encoder)
    }
}
