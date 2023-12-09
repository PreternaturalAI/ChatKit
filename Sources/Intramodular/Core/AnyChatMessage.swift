//
// Copyright (c) Vatsal Manot
//

import Swallow

public typealias ChatMessageConvertible = AnyChatMessageConvertible

/// A type that can be converted to a type-erased chat message.
public protocol AnyChatMessageConvertible {
    func __conversion() -> AnyChatMessage
}

public protocol ChatItem: Identifiable<AnyChatItemIdentifier> where ID == AnyChatItemIdentifier {
    var id: AnyChatItemIdentifier { get }
}

public struct AnyChatMessage: ChatItem, Hashable, Identifiable, AnyChatMessageConvertible {
    public let id: AnyChatItemIdentifier
    @_HashableExistential
    public var role: any ChatItemRole
    public let body: String
    
    public init(
        id: AnyChatItemIdentifier,
        role: any ChatItemRole,
        body: String
    ) {
        self.id = id
        self.role = role
        self.body = body
    }
    
    public init(_ text: String) {
        self.init(
            id: .init(base: UUID()),
            role: ChatItemRoles.SenderRecipient.sender,
            body: text
        )
    }
    
    public func __conversion() -> AnyChatMessage {
        self
    }
}

// MARK: - Extensions

extension AnyChatMessage {
    public init<ID: Hashable>(
        id: ID,
        isSender: Bool,
        body: String
    ) {
        self.init(
            id: .init(base: id),
            role: isSender ? ChatItemRoles.SenderRecipient.sender : ChatItemRoles.SenderRecipient.recipient,
            body: body
        )
    }
}

// MARK: - Properties

extension AnyChatMessage {
    public var isSender: Bool {
        get throws {
            if let role = role as? ChatItemRoles.SenderRecipient {
                return role == .sender
            } else {
                throw Never.Reason.unimplemented
            }
        }
    }
}
