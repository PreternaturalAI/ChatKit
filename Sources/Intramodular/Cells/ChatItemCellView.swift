//
// Copyright (c) Vatsal Manot
//

import MarkdownUI
import Swallow
import SwiftUIZ

public struct ChatItemCellView: View {
    @Environment(\._chatItemViewActions) var _chatItemViewActions
    
    private let item: AnyChatMessage
    private var _actions: _ChatItemCellViewActions = nil
    
    @State private var isEditing: Bool = false
    
    fileprivate var actions: _ChatItemCellViewActions {
        _chatItemViewActions.mergingInPlace(with: _actions)
    }
    
    public init(
        item: AnyChatMessage
    ) {
        self.item = item
    }
    
    public var body: some View {
        Group {
            let message = item
            
            _TextChatMessageViewContent(
                message: message,
                isEditing: $isEditing
            )
            .modify(for: .visionOS) { content in
                content
                    .padding(.extraSmall)
            }
            .padding(try! message.isSender ? .trailing : .leading, .extraSmall)
            .frame(minWidth: 44, minHeight: 10)
            .modifier(
                _iMessageBubbleStyle(
                    isSender: try! message.isSender,
                    isBorderless: false
                )
            )
        }
        .frame(width: .greedy, alignment: try! item.isSender  ? .trailing : .leading)
        .contentShape(Rectangle())
        .contextMenu {
            _ContextMenu(isEditing: $isEditing)
        }
        .transformEnvironment(\._chatItemViewActions) {
            $0 = $0.mergingInPlace (with: actions)
        }
        .chatItem(id: item.id, role: item.role)
    }
}

extension ChatItemCellView {
    fileprivate struct _ContextMenu: View {
        @Environment(\._chatItemViewActions) var actions
        
        @Binding var isEditing: Bool
        
        var body: some View {
            if actions.onEdit != nil {
                Button("Edit") {
                    isEditing = true
                }
            }
            
            if let onDelete = actions.onDelete {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            }
            
            if let onResend = actions.onResend {
                Button("Resend") {
                    onResend()
                }
            }
        }
    }
}

extension ChatItemCellView {
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