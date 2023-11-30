//
// Copyright (c) Vatsal Manot
//

import MarkdownUI
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
extension _TextChatMessageViewContent {
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
extension _TextChatMessageViewContent {
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
#endif


#if os(iOS) || os(tvOS) || os(visionOS)
extension AppKitOrUIKitFont {
    func scaled(
        by ratio: CGFloat
    ) -> AppKitOrUIKitFont {
        let newPointSize = pointSize * ratio
        
        return AppKitOrUIKitFont(
            descriptor: fontDescriptor,
            size: newPointSize
        )
    }
}
#elseif os(macOS)
extension AppKitOrUIKitFont {
    func scaled(by ratio: CGFloat) -> NSFont {
        let newPointSize = pointSize * ratio
        
        guard let font = NSFont(
            descriptor: fontDescriptor,
            size: newPointSize
        ) else {
            assertionFailure()
            
            return self
        }
        
        return font
    }
}
#endif
