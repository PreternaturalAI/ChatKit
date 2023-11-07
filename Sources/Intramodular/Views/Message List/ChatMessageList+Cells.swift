//
// Copyright (c) Vatsal Manot
//

import MarkdownUI
import Swallow
import SwiftUIX

struct ChatItemActions: ExpressibleByNilLiteral {
    var onEdit: ((String) -> Void)?
    var onDelete: (() -> Void)?
    var onResend: (() -> Void)?
    
    init(
        onEdit: ((String) -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onResend: (() -> Void)? = nil
    ) {
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onResend = onResend
    }
    
    init(nilLiteral: ()) {
        
    }
    
    func updating(with other: Self) -> Self {
        var result = self
        
        result.onEdit = other.onEdit
        result.onDelete = other.onDelete
        result.onResend = other.onResend
        
        return result
    }
}

extension EnvironmentValues {
    struct ChatItemActionsKey: EnvironmentKey {
        static var defaultValue: ChatItemActions = nil
    }
    
    var _chatItemActions: ChatItemActions {
        get {
            self[ChatItemActionsKey.self]
        } set {
            self[ChatItemActionsKey.self] = newValue
        }
    }
}

public struct ChatMessageView: View {
    @Environment(\._chatItemActions) var _chatItemActions
    
    private let message: ChatMessage
    private var _actions: ChatItemActions = nil
    
    @State private var isEditing: Bool = false
    
    fileprivate var actions: ChatItemActions {
        _chatItemActions.updating(with: _actions)
    }
    
    public init(
        message: ChatMessage
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
        let message: ChatMessage
        
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
