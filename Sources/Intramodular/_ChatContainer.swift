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
        Group {
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

// MARK: - Auxiliary -

public enum MessageDeliveryState {
    case sending
    case errored
    case idle
}

public struct ChatViewProperties: ExpressibleByNilLiteral {
    var messageDeliveryState: MessageDeliveryState?
    var interrupt: (() -> Void)?
    
    public init(nilLiteral: ()) {
        self.messageDeliveryState = nil
    }
}

extension EnvironmentValues {
    struct ChatViewKey: EnvironmentKey {
        static let defaultValue: ChatViewProperties? = nil
    }
    
    public var _chatContainer: ChatViewProperties? {
        get {
            self[ChatViewKey.self]
        } set {
            self[ChatViewKey.self] = newValue
        }
    }
}
