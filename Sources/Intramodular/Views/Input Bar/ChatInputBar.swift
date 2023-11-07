//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

public struct ChatInputBar: View {
    @Environment(\._chatContainer) private var _chatContainer: ChatViewProperties!
    @Environment(\._chatInputBarStyle) private var chatInputBarStyle
    @Environment(\.isEnabled) private var isEnabled
    
    private let onSubmit: (String) -> Void
    
    @Binding private var text: String
    
    public init(
        text: Binding<String>,
        onSubmit: @escaping (String) -> Void = { _ in }
    ) {
        self._text = text
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        if _chatContainer != nil {
            _WithDynamicPropertyExistential(chatInputBarStyle) {
                $0.makeBody(
                    configuration: .init(
                        textInput: _chatContainer.messageDeliveryState != .sending ? textView.eraseToAnyView() : nil,
                        status: _chatContainer.messageDeliveryState == nil ? nil : statusView.eraseToAnyView()
                    )
                )
            }
        } else {
            _UnimplementedView()
        }
    }
    
    @ViewBuilder
    public var statusView: some View {
        Group {
            switch _chatContainer.messageDeliveryState {
                case .sending:
                    if let interrupt = _chatContainer.interrupt {
                        Button("Stop") {
                            interrupt()
                        }
                        .controlSize(.large)
                        .buttonStyle(.bordered)
                        .environment(\.isEnabled, true)
                    } else {
                        ProgressView()
                            .controlSize(.regular)
                            .progressViewStyle(.circular)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                default:
                    EmptyView()
            }
        }
    }
    
    private var textView: some View {
        TextView("Enter a message here", text: $text, onCommit: {
            onSubmit(text)
            
            DispatchQueue.main.async {
                text = ""
            }
        })
        .foregroundColor(.primary)
        .dismissKeyboardOnReturn(true)
    }
}
