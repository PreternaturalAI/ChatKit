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
                .animation(.default, value: _chatContainer.messageDeliveryState)
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
                    if let stop = _chatContainer.interrupt {
                        makeStopButton(action: stop)
                    } else {
                        sendActivityDisclosure
                    }
                default:
                    EmptyView()
            }
        }
    }
    
    private func makeStopButton(
        action: @escaping () -> Void
    ) -> some View {
        Button("Stop") {
            action()
        }
        .controlSize(.large)
        .buttonStyle(.bordered)
        .environment(\.isEnabled, true)
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
        .transition(.opacity.animation(.default))
    }
    
    private var sendActivityDisclosure: some View {
        ProgressView()
            .controlSize(.regular)
            .progressViewStyle(.circular)
            .font(.body)
            .foregroundColor(.secondary)
    }
}
