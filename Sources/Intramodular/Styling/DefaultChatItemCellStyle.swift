//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

struct DefaultChatItemCellStyle: ChatItemCellStyle {
    func body(
        configuration: ChatItemCellConfiguration
    ) -> some View {
        makeContent(configuration: configuration)
            .modifier(
                _iMessageBubbleStyle(
                    isSender: try! configuration.item.isSender,
                    isBorderless: false,
                    error: configuration.item.activityPhase?.error
                )
            )
            ._formStackByAdding(
                .horizontal,
                try! configuration.item.isSender ? .leading : .trailing
            ) {
                if let decoration = configuration.decorations[.besideItem] {
                    decoration
                }
            }
            .background(Color.almostClear)
            .contextMenu {
                _ContextMenu()
            }
    }
    
    @ViewBuilder
    private func makeContent(
        configuration: ChatItemCellConfiguration
    ) -> some View {
        let message: AnyChatMessage = configuration.item
        
        Group {
            if message.body != nil {
                _TextChatMessageViewContent(
                    message: message,
                    isEditing: configuration.$isEditing
                )
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
        var body: some View {
            ChatItemActions()
        }
    }
}

public struct ChatItemActions: View {
    @Environment(\._chatItemConfiguration) var _chatItemConfiguration
    @Environment(\._chatItemState) var _chatItemState

    public init() {
        
    }
    
    public var body: some View {
        if let _chatItemState = _chatItemState {
            if _chatItemConfiguration.onEdit != nil {
                Button(_chatItemState.isEditing ? "End Editing" : "Edit") {
                    _chatItemState.isEditing = true
                }
            }
            
            if let onDelete = _chatItemConfiguration.onDelete {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            }
            
            if let onResend = _chatItemConfiguration.onResend {
                Button("Resend") {
                    onResend()
                }
            }
        } else {
            _UnimplementedView()
        }
    }
}

extension EnvironmentValues {
    @EnvironmentValue
    var _chatItemState: _ChatItemState?
}

struct _ChatItemState {
    @Binding var isEditing: Bool
}
