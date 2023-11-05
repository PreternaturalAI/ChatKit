//
// Copyright (c) Vatsal Manot
//

import MarkdownUI
import Swallow
import SwiftUIX
public struct ChatMessageView: View {
    struct ProvidedActions: ExpressibleByNilLiteral {
        var onEdit: ((String) -> Void)?
        var onDelete: (() -> Void)?
        var onResend: (() -> Void)?
        
        init(nilLiteral: ()) {
            
        }
    }
    
    private let message: ChatMessage
    private var actions: ProvidedActions = nil
    
    @State private var isEditing: Bool = false
    
    public init(
        message: ChatMessage
    ) {
        self.message = message
    }
    
    public var body: some View {
        Group {
            TextContent(
                message: message,
                supportedActions: actions,
                isEditing: $isEditing
            )
        }
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
    }
    
    public func onEdit(
        perform fn: @escaping (String) -> Void
    ) -> Self {
        then {
            $0.actions.onEdit = fn
        }
    }
    
    public func onDelete(
        perform fn: @escaping () -> Void
    ) -> Self {
        then {
            $0.actions.onDelete = fn
        }
    }
    
    public func onResend(
        perform fn: @escaping () -> Void
    ) -> Self {
        then {
            $0.actions.onResend = fn
        }
    }
}

extension ChatMessageView {
    struct TextContent: View {
        let message: ChatMessage
        let supportedActions: ChatMessageView.ProvidedActions
        
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
                        markdownBody
                    }
                }
            }
            .font(.body)
            .foregroundStyle(.primary)
            .padding(message.isSender ? .trailing : .leading, .extraSmall)
            .frame(minWidth: 44, minHeight: 10)
            .modifier(
                RegularMessageBubbleStyle(
                    isSender: message.isSender,
                    contentExtendsToEdges: false
                )
            )
        }
        
        private var markdownBody: some View {
            VStack(alignment: .leading, spacing: 0) {
                Markdown(message.body)
                    .markdownTheme(.docC)
                    .textSelection(.enabled)
            }
        }
    }
}
