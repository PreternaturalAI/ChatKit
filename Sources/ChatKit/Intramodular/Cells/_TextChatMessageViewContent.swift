//
// Copyright (c) Vatsal Manot
//

import MarkdownUI
@_spi(Internal) import SwiftUIX
import SwiftUIZ

struct _TextChatMessageViewContent: View {
    @Environment(\._chatItemConfiguration) var _chatItemConfiguration
    
    let message: AnyChatMessage
    
    @Binding var isEditing: Bool
    
    @State private var editableText: String?
    
    var body: some View {
        let messageBody: String = message.body!

        Group {
            if isEditing, let onEdit = _chatItemConfiguration.onEdit {
                EditableText(
                    text: $editableText.withDefaultValue(messageBody),
                    isEditing: .constant(true)
                ) {
                    isEditing = false
                    
                    onEdit(AnyChatItemContent(content: $0))
                }
                .lineLimit(nil)
            } else {
                if messageBody.isEmpty {
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
    private struct MarkdownBody: View {
        let text: String
        
        init(_ text: String) {
            self.text = text
        }
        
        var body: some View {
            Markdown(text)
                .equatable()
                .markdownTheme(.docC)
        }
    }

    @ViewBuilder
    var _staticTextView: some View {
        if let messageBody = message.body {
            MarkdownBody(messageBody)
                .font(.body)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
        } else {
            _UnimplementedView()
        }
    }
}
#elseif os(visionOS)
extension _TextChatMessageViewContent {
    @ViewBuilder
    var _staticTextView: some View {
        if let body = message.body {
            Text(body)
                .font(.body.scaled(by: 1.2))
                .fixedSize(horizontal: false, vertical: true)
                .contentTransition(.opacity)
                .animation(.default, value: message.body)
        }
    }
}
#endif
