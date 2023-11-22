//
// Copyright (c) Vatsal Manot
//

import MarkdownUI
import Swallow
import SwiftUIZ

public struct ChatMessageView: View {
    @Environment(\._chatItemActions) var _chatItemActions
    
    private let message: AnyChatMessage
    private var _actions: ChatItemActions = nil
    
    @State private var isEditing: Bool = false
    
    fileprivate var actions: ChatItemActions {
        _chatItemActions.updating(with: _actions)
    }
    
    public init(
        message: AnyChatMessage
    ) {
        self.message = message
    }
    
    public var body: some View {
        Group {
            TextContent(
                message: message,
                isEditing: $isEditing
            )
        }
        .contentShape(Rectangle())
        .contextMenu {
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
        .transformEnvironment(\._chatItemActions) {
            $0 = $0.updating(with: actions)
        }
    }
    
    public func onEdit(
        perform fn: ((String) -> Void)?
    ) -> Self {
        then {
            $0._actions.onEdit = fn
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

extension ChatMessageView {
    struct TextContent: View {
        @Environment(\._chatItemActions) var supportedActions
        let message: AnyChatMessage
        
        @Binding var isEditing: Bool
        
        @State private var editableText: String?
        
        var body: some View {
            Group {
                if isEditing, let onEdit = supportedActions.onEdit {
                    EditableText(
                        text: $editableText.withDefaultValue(message.body),
                        isEditing: .constant(true)
                    ) {
                        isEditing = false
                        
                        onEdit($0)
                    }
                    .lineLimit(nil)
                } else {
                    if message.body.isEmpty {
                        Text("This message has no content.")
                            .foregroundColor(.secondary)
                    } else {
                        MarkdownBody(text: message.body)
                            .equatable()
                    }
                }
            }
            .font(.body)
            .foregroundStyle(.primary)
            .padding(try! message.isSender ? .trailing : .leading, .extraSmall)
            .frame(minWidth: 44, minHeight: 10)
            .modifier(
                RegularMessageBubbleStyle(
                    isSender: try! message.isSender,
                    contentExtendsToEdges: false
                )
            )
        }
        
        struct MarkdownBody: Equatable, View {
            let text: String
            
            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    Markdown(text)
                        .markdownTheme(.docC)
                        .textSelection(.enabled)
                }
            }
        }
    }
}
