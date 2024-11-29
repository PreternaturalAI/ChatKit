//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol ChatItem: Identifiable<AnyChatItemIdentifier> where ID == AnyChatItemIdentifier {
    var id: AnyChatItemIdentifier { get }
}

/// A type that can be converted to a type-erased chat message.
public protocol AnyChatMessageConvertible {
    func __conversion() -> AnyChatMessage
}

public typealias ChatMessageConvertible = AnyChatMessageConvertible
