//
// Copyright (c) Vatsal Manot
//

import MarkdownUI
@_spi(Internal) import SwiftUIX
import SwiftUIZ

struct _TextChatMessageViewContent: View {
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
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                } else {
                    _staticTextView
                }
            }
        }
        .font(.body)
        .foregroundStyle(.primary)
        .textSelection(.enabled)
    }
}

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
extension _TextChatMessageViewContent {
    private struct MarkdownBody: Equatable, View {
        let text: String
        
        init(_ text: String) {
            self.text = text
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Markdown(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
            }
            .markdownTheme(.docC)
        }
    }
    
    var _staticTextView: some View {
        MarkdownBody(message.body)
            .font(.body)
            .foregroundStyle(Color.label)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
    }
}
#elseif os(visionOS)
extension _TextChatMessageViewContent {
    @ViewBuilder
    var _staticTextView: some View {
        Text(message.body)
            .font(.body.scaled(by: 1.5))
            .contentTransition(.opacity)
            .animation(.default, value: message.body)
    }
}
#endif
