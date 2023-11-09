//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIZ

@_ViewTrait
public struct ChatItemConfiguration: Identifiable {
    public var id: AnyChatItemIdentifier
    @_HashableExistential
    public var role: any ChatItemRole
}

@_ViewTraitKey(for: ChatItemConfiguration.self, named: "_chatItemConfiguration")
extension _ViewTraitKeys { }

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
