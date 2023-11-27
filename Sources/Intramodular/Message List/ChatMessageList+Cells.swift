//
// Copyright (c) Vatsal Manot
//

import MarkdownUI
import Swallow
import SwiftUIZ

public struct _ChatItemContentView: View {
    @Environment(\._chatItemViewActions) var _chatItemViewActions
    
    private let message: AnyChatMessage
    private var _actions: _ChatItemViewActions = nil
    
    @State private var isEditing: Bool = false
    
    fileprivate var actions: _ChatItemViewActions {
        _chatItemViewActions.mergingInPlace(with: _actions)
    }
    
    public init(
        message: AnyChatMessage
    ) {
        self.message = message
    }
    
    public var body: some View {
        Group {
            _TextMessageViewContent(
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
                RegularMessageBubbleStyle(
                    isSender: try! message.isSender,
                    contentExtendsToEdges: false
                )
            )
        }
        .contentShape(Rectangle())
        .contextMenu {
            _ContextMenu(isEditing: $isEditing)
        }
        .transformEnvironment(\._chatItemViewActions) {
            $0 = $0.mergingInPlace (with: actions)
        }
    }
}

extension _ChatItemContentView {
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

extension _ChatItemContentView {
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

struct _TextMessageViewContent: View {
    @Environment(\._chatItemViewActions) var supportedActions
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
                    
                    onEdit(.init(content: $0))
                }
                .lineLimit(nil)
            } else {
                if message.body.isEmpty {
                    Text("This message has no content.")
                        .foregroundColor(.secondary)
                } else {
                    _staticTextView
                }
            }
        }
        .font(.body)
        .foregroundStyle(.primary)
    }
}

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
extension _TextMessageViewContent {
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
    
    var _staticTextView: some View {
        MarkdownBody(text: message.body)
            .equatable()
    }
}
#elseif os(visionOS)
extension _TextMessageViewContent {
    @ViewBuilder
    var _staticTextView: some View {
        Text(message.body)
            .font(.body.scaled(by: 1.5))
            .contentTransition(.opacity)
            .animation(.default, value: message.body)
    }
}

extension Font {
    public func scaled(by ratio: CGFloat) -> Self {
        (try? toAppKitOrUIKitFont().scaled(by: ratio)).map({ Font($0) }) ?? self
    }
}

extension UIFont {
    func scaled(by ratio: CGFloat) -> UIFont {
        let newPointSize = pointSize * ratio
        
        return UIFont(descriptor: fontDescriptor, size: newPointSize)
    }
}
#endif
