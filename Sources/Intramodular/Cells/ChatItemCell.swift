//
// Copyright (c) Vatsal Manot
//

import MarkdownUI
import Swallow
import SwiftUIZ

public struct ChatItemCell: View {
    @Environment(_type: (any ChatItemCellStyle).self) var chatItemCellStyle
    
    @Environment(\._chatItemViewActions) var _chatItemViewActions
    
    private var item: AnyChatMessage
    private var _actions: _ChatItemCellActions = nil
    
    @State private var isEditing: Bool = false
    
    fileprivate var actions: _ChatItemCellActions {
        _chatItemViewActions.mergingInPlace(with: _actions)
    }
    
    public init(
        item: AnyChatMessage
    ) {
        self.item = item
    }
    
    public init(
        item: some ChatMessageConvertible
    ) {
        self.item = item.__conversion()
    }
    
    public var body: some View {
        _WithDynamicPropertyExistential(chatItemCellStyle ?? DefaultChatItemCellStyle()) { (style: (any ChatItemCellStyle)) in
            style
                .body(configuration: ChatItemCellConfiguration(item: item, isEditing: $isEditing))
                .eraseToAnyView()
        }
        .transformEnvironment(\._chatItemViewActions) {
            $0 = $0.mergingInPlace(with: actions)
        }
        .transition(.opacity.animation(.default))
        .chatItem(id: item.id, role: item.role)
    }
    
    public func roleInvert(_ active: Bool = false) -> Self {
        withMutableScope(self) {
            if active {
                $0.item.role = try! item.role.invertRole()
            }
        }
    }
}

extension ChatItemCell {
    public func onEdit(
        perform fn: ((String) -> Void)?
    ) -> Self {
        then {
            if let fn {
                $0._actions.onEdit = { fn($0.content) }
            }
        }
    }
    
    public func onDelete(
        perform fn: (() -> Void)?
    ) -> Self {
        then {
            $0._actions.onDelete = fn
        }
    }
    
    public func onResend(
        perform fn: (() -> Void)?
    ) -> Self {
        then {
            $0._actions.onResend = fn
        }
    }
}

struct _ExpandAndAlignChatItem: ViewModifier {
    let item: _ChatItemConfiguration
    
    func body(content: Content) -> some View {
        let role = item.role as! ChatItemRoles.SenderRecipient
        
        _IntrinsicGeometryValueReader(\.width) { width in
            content
                .frame(
                    maxWidth: min((width ?? (800 / 0.7)) * 0.7, 800),
                    alignment: role == .sender ? .trailing : .leading
                )
                .frame(
                    width: .greedy,
                    alignment: role == .sender ? .trailing : .leading
                )
        }
    }
}
