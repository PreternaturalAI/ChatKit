//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

public struct ChatItemConfiguration: Identifiable {
    public var id: AnyChatItemIdentifier
    @_HashableExistential
    public var role: any ChatItemRole
}

extension View {
    public func chatItem<T: Hashable>(
        id: T,
        role: any ChatItemRole
    ) -> some View {
        _trait(\._chatItemConfiguration, .init(id: .init(base: id), role: role))
    }
    
    public func chatMessage<T: Hashable>(
        id: T,
        role: ChatItemRoles.SenderRecipient
    ) -> some View {
        chatItem(id: id, role: role)
    }
}

extension _ViewTraitKeys {
    struct _ChatItemConfigurationKey: _ViewTraitKey {
        typealias Value = ChatItemConfiguration?
        
        static var defaultValue: ChatItemConfiguration? = nil
    }
    
    var _chatItemConfiguration: _ChatItemConfigurationKey.Type {
        _ChatItemConfigurationKey.self
    }
}
