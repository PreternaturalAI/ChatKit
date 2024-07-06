//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIZ

@_ViewTrait
public struct _ChatItemTraitValue: Identifiable {
    public var id: AnyChatItemIdentifier
    @_HashableExistential
    public var role: any ChatItemRole
}

// MARK: - Auxiliary

@_ViewTraitKey(for: _ChatItemTraitValue.self, named: "_chatItemTraitValue")
extension _ViewTraitKeys { }

extension View {
    public func chatItem<T: Hashable>(
        id: T,
        role: any ChatItemRole
    ) -> some View {
        withEnvironmentValue(\._chatViewActions) { actions in
            let id = AnyChatItemIdentifier(base: id)
            
            self
                .environment(\._chatItemConfiguration, merging: _ChatItemConfiguration(id: id, actions: actions))
                ._trait(\._chatItemTraitValue, _ChatItemTraitValue(id: id, role: role))
        }
    }
    
    public func chatMessage<T: Hashable>(
        id: T,
        role: ChatItemRoles.SenderRecipient
    ) -> some View {
        chatItem(id: id, role: role)
    }
}
