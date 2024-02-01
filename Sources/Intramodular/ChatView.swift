//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX
import SwiftUIZ

public enum _ChatViewElement {
    case items
}

/// A view that contains a chat interface.
public struct ChatView<Content: View>: View {
    @Environment(\._chatViewPreferences) var _inheritedChatViewPreferences
    
    let content: Content
    let inputView: AnyView?
    
    @State public var _chatViewPreferences = _ChatViewPreferences()
    
    public var body: some View {
        _ViewLevel { level in
            UnaryViewAdaptor {
                XStack(alignment: .top) {
                    content
                }
            }
            .modify(forUnwrapped: inputView) { inputView in
                AnyViewModifier {
                    $0._bottomBar {
                        inputView
                            .padding(.horizontal)
                    }
                }
            }
            .environment(\._chatViewPreferences, (_inheritedChatViewPreferences ?? .init()).mergingInPlace(with: _chatViewPreferences))
            .onPreferenceChange(_ChatViewPreferences._PreferenceKey.self) {
                self._chatViewPreferences = $0
            }
        }
    }
}

extension View {
    public func activityPhaseOfLastItem(
        _ state: ChatItemActivityPhase
    ) -> some View {
        environment(\._chatViewPreferences, merging: .init(activityPhaseOfLastItem: state))
    }
    
    public func onChatInterrupt(
        perform action: @escaping () -> Void
    ) -> some View {
        withActionTrampoline(for: Action(action)) { action in
            environment(\._chatViewPreferences, merging: .init(interrupt: action))
        }
    }
    
    @available(*, deprecated, renamed: "activityPhaseOfLastItem")
    public func messageDeliveryState(
        _ state: ChatItemActivityPhase
    ) -> some View {
        activityPhaseOfLastItem(state)
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
