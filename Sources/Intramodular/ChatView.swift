//
// Copyright (c) Vatsal Manot
//

import SwiftUIZ

/// A view that contains a chat interface.
public struct ChatView<Content: View>: View {
    @Environment(\._chatViewPreferences) var _inheritedChatViewPreferences
    
    let content: Content
    let inputView: AnyView?
    
    @State public var _chatViewPreferences = _ChatViewPreferences()
    
    public var body: some View {
        ViewAssociationLevel { level in
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
            .environment(
                \._chatViewPreferences,
                 (_inheritedChatViewPreferences ?? .init()).mergingInPlace(with: _chatViewPreferences)
            )
        }
        .onPreferenceChange(_ChatViewPreferences._PreferenceKey.self) {
            self._chatViewPreferences = $0
        }
    }
}

extension View {
    public func messageDeliveryState(
        _ state: MessageDeliveryState
    ) -> some View {
        environment(\._chatViewPreferences, merging: .init(messageDeliveryState: state))
    }
    
    /*public func onInterrupt(
        perform action: @escaping () -> Void
    ) -> Self {
        then {
            $0.properties.interrupt = action
        }
    }*/
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
