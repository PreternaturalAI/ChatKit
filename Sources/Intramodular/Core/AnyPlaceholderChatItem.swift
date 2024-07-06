//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

struct AnyPlaceholderChatItem: ChatMessageConvertible {
    static let id = AnyChatItemIdentifier(base: UUID())
    
    func __conversion() -> AnyChatMessage {
        AnyChatMessage(
            id: Self.id,
            role: ChatItemRoles.SenderRecipient.recipient,
            body: nil
        )
    }
}
