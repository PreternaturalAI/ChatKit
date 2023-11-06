//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

/// A view that contains a chat interface.
public struct ChatView<Content: View>: View {
    let content: Content
    let inputView: AnyView?
    
    var properties: ChatViewProperties = nil
    
    public var body: some View {
        XStack {
            content
        }
        .modify(forUnwrapped: inputView) { inputView in
            AnyViewModifier {
                $0._bottomBar {
                    inputView
                        .padding(.horizontal)
                }
            }
        }
        .environment(\._chatContainer, properties)
    }
    
    public func messageDeliveryState(
        _ state: MessageDeliveryState
    ) -> Self {
        then {
            $0.properties.messageDeliveryState = state
        }
    }
    
    public func onInterrupt(
        perform action: @escaping () -> Void
    ) -> Self {
        then {
            $0.properties.interrupt = action
        }
    }
}

// MARK: - Initializers

extension ChatView {
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.inputView = nil
    }
    
    public init<Input: View>(
        @ViewBuilder content: () -> Content,
        @ViewBuilder input: () -> Input
    ) {
        self.content = content()
        self.inputView = input().eraseToAnyView()
    }
}
