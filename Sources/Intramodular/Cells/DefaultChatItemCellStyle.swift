//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

struct DefaultChatItemCellStyle: ChatItemCellStyle {
    func body(
        configuration: ChatItemCellConfiguration
    ) -> some View {
        makeContent(configuration: configuration)
            .modifier(
                _iMessageBubbleStyle(
                    isSender: try! configuration.item.isSender,
                    isBorderless: false
                )
            )
    }
    
    @ViewBuilder
    private func makeContent(configuration: ChatItemCellConfiguration) -> some View {
        let message = configuration.item
        
        Group {
            if message.body != nil {
                _TextChatMessageViewContent(
                    message: message,
                    isEditing: configuration.$isEditing
                )
                .contextMenu {
                    _ContextMenu(isEditing: configuration.$isEditing)
                }
                .modify(for: .visionOS) { content in
                    content
                        .padding(.extraSmall)
                }
                .frame(minWidth: 44, minHeight: 10)
            } else if let activityPhase = message.activityPhase {
                _AnyChatItemPlaceholderContent(phase: activityPhase)
            } else {
                _UnimplementedView()
            }
        }
        .padding(try! message.isSender ? .trailing : .leading, .extraSmall)
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
