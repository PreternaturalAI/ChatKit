//
// Copyright (c) Vatsal Manot
//

import CorePersistence

public struct AnyChatItemContent: Codable, Hashable, Sendable {
    public var content: String
    
    public init(content: String) {
        self.content = content
    }
}
