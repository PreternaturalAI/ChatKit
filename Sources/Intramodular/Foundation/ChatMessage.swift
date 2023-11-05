//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol ChatMessageConvertible {
    func toChatMessage() -> ChatMessage
}

public struct ChatMessage: Hashable, Identifiable {
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
}

// MARK: - Extensions

extension ChatMessage {
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

extension ChatMessage {
    public var isSender: Bool {
        if let role = role as? ChatItemRoles.SenderRecipient {
            return role == .sender
        } else {
            assertionFailure(.unimplemented)
            
            return false
        }
    }
}
