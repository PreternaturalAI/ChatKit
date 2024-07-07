//
// Copyright (c) Vatsal Manot
//

import MarkdownUI
import Swallow
import SwiftUIZ

public struct ChatItemCell: Identifiable, View {
    @Environment(_type: (any ChatItemCellStyle).self) var chatItemCellStyle
    
    @Environment(\._chatItemConfiguration) var _chatItemConfiguration
    @Environment(\._chatViewPreferences) var _chatViewPreferences

    public var id: AnyChatItemIdentifier {
        item.id
    }
    
    private var item: AnyChatMessage
    private var explicitItemConfiguration: _ChatItemConfiguration = nil
    
    @State private var isEditing: Bool = false
    
    fileprivate var itemConfiguration: _ChatItemConfiguration {
        _chatItemConfiguration.mergingInPlace(with: explicitItemConfiguration)
    }
    
    public init(
        item: some ChatMessageConvertible
    ) {
        self.item = item.__conversion()
    }
    
    public var body: some View {
        _WithDynamicPropertyExistential(chatItemCellStyle ?? iMessageChatItemCellStyle()) { (style: (any ChatItemCellStyle)) -> (any View) in
            let item2: AnyChatMessage = withMutableScope(item) {
                if let phase = (itemConfiguration.activityPhase ?? $0.activityPhase) ?? _chatViewPreferences.itemActivityPhaseByItem[id], phase != .idle {
                    $0.activityPhase = phase
                }
            }

            style.body(
                configuration: ChatItemCellConfiguration(
                    item: item2,
                    decorations: _chatItemConfiguration.decorations,
                    isEditing: $isEditing
                )
            )
        }
        .environment(\._chatItemConfiguration, itemConfiguration)
        .environment(\._chatItemState, _ChatItemState(isEditing: $isEditing))
        .transition(.opacity.animation(.default))
        .chatItem(id: item.id, role: item.role)
    }
}

extension ChatItemCell {
    public func roleInvert(
        _ active: Bool = false
    ) -> Self {
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
                $0.explicitItemConfiguration.onEdit = { fn($0.content) }
            }
        }
    }
    
    public func onDelete(
        perform fn: (() -> Void)?
    ) -> Self {
        then {
            $0.explicitItemConfiguration.onDelete = fn
        }
    }
    
    public func onResend(
        perform fn: (() -> Void)?
    ) -> Self {
        then {
            $0.explicitItemConfiguration.onResend = fn
        }
    }
}

struct _ExpandAndAlignChatItem: ViewModifier {
    let item: _ChatItemTraitValue
    
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
