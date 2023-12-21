//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

struct DefaultChatItemCellStyle: ChatItemCellStyle {
    func body(
        configuration: ChatItemCellConfiguration
    ) -> some View {
        Group {
            let message = configuration.item
            
            _TextChatMessageViewContent(
                message: message,
                isEditing: configuration.$isEditing
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
        .frame(width: .greedy, alignment: try! configuration.item.isSender  ? .trailing : .leading)
        .contentShape(Rectangle())
        .contextMenu {
            _ContextMenu(isEditing: configuration.$isEditing)
        }
    }
    
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
