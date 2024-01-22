//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

public struct ChatMessageList<Data: RandomAccessCollection>: View where Data.Element: Identifiable {
    @Environment(\._chatViewPreferences) private var _chatViewPreferences
    
    private let _content : AnyView
    private var _chatViewActions = _ChatViewActions()
    
    private enum ImplementationStrategy {
        case a
        case b
        case c
    }
    
    /// Whether `SwiftUI`'s official `List` implementation is garbage.
    private var _isOfficialImplementationStillFucked: Bool {
        false
    }
    
    private var implementationStrategy: ImplementationStrategy {
        #if os(macOS)
        if _isOfficialImplementationStillFucked {
            ImplementationStrategy.c // SwiftUIX.CocoaList
        } else {
            ImplementationStrategy.b // SwiftUI.List
        }
        #elseif os(iOS) || os(visionOS)
        ImplementationStrategy.a // LazyVStack + ScrollView
        #endif
    }

    init<C: View>(_content: () -> C) {
        self._content = _content().eraseToAnyView()
    }
                
    public var body: some View {
        switch implementationStrategy {
            case .a:
                _ChatMessageListA {
                    _content
                }
            case .b:
                _ChatMessageListB {
                    _content
                }
            case .c:
                _ChatMessageListC {
                    _content
                }
        }
    }
}

// MARK: - Initializers

extension ChatMessageList {
    public init(
        _ data: Data
    ) where Data.Element: ChatMessageConvertible {
        self.init {
            ForEach(data) { item in
                let item = item.__conversion()
                
                withEnvironmentValue(\._chatViewActions) { actions in
                    ChatItemCell(item: item)
                        .chatItem(
                            id: item.id,
                            role: item.role
                        )
                        .environment(\._chatItemViewActions, .init(from: actions, id: item.id))
                }
            }
        }
    }

    public init<Content: View>(
        _ data: Data,
        content: @escaping (Data.Element) -> Content
    ) where Data.Element: ChatMessageConvertible {
        self.init {
            ForEach(data) { item in
                let chatItem = item.__conversion()
                
                withEnvironmentValue(\._chatViewActions) { actions in
                    content(item)
                        .chatItem(
                            id: chatItem.id,
                            role: chatItem.role
                        )
                        .environment(\._chatItemViewActions, .init(from: actions, id: chatItem.id))
                }
            }
        }
    }
    
    public init<Content: View>(
        _ data: Data,
        content: @escaping (Data.Element) -> Content
    ) {
        self.init {
            _VariadicViewAdapter {
                ForEach(data) { item in
                    content(item)
                }
            } content: { content in
                withEnvironmentValue(\._chatViewActions) { actions in
                    _ForEachSubview(content, trait: \._chatItemConfiguration) { subview, chatItem in
                        subview
                            .environment(\._chatItemViewActions, .init(from: actions, id: chatItem.id))
                            .chatItem(
                                id: chatItem.id,
                                role: chatItem.role
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Modifiers

extension ChatMessageList {
    public func onDelete(
        perform fn: @escaping (Data.Element.ID) -> Void
    ) -> Self {
        then {
            $0._chatViewActions.onDelete = { fn($0.as(Data.Element.ID.self)) }
        }
    }
    
    public func onResend(
        perform fn: @escaping (Data.Element.ID) -> Void
    ) -> Self {
        then {
            $0._chatViewActions.onResend = { fn($0.as(Data.Element.ID.self)) }
        }
    }
}
