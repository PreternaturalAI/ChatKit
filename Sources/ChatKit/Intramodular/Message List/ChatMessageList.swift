//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

public struct ChatMessageList<Data: RandomAccessCollection>: View where Data.Element: Identifiable {
    @Environment(\._chatViewPreferences) private var _chatViewPreferences: _ChatViewPreferences
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom: UserInterfaceIdiom
    
    private let _content : AnyView
    private var _chatViewActions = _ChatViewActions()
    
    private enum ImplementationStrategy {
        case a // LazyVStack + ScrollView
        case b // SwiftUI.List
        case c // SwiftUIX.CocoaList
    }
    
    /// Whether `SwiftUI`'s official `List` implementation is garbage.
    private var _isOfficialImplementationStillFucked: Bool {
        false
    }
    
    private var implementationStrategy: ImplementationStrategy {
        if userInterfaceIdiom == .mac {
            if _isOfficialImplementationStillFucked {
                return ImplementationStrategy.c // SwiftUIX.CocoaList
            } else {
                return ImplementationStrategy.b // SwiftUI.List
            }
        } else if userInterfaceIdiom == .phone || userInterfaceIdiom == .vision {
            return ImplementationStrategy.a
        } else {
            return ImplementationStrategy.a
        }
    }
    
    init<C: View>(_content: () -> C) {
        self._content = _content().eraseToAnyView()
    }
    
    public var body: some View {
        Group {
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
        .transformEnvironment(\._chatViewActions) {
            $0.mergeInPlace(with: _chatViewActions)
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
                
                ChatItemCell(item: item)
                    .chatItem(id: item.id, role: item.role)
            }
        }
    }
    
    public init<Content: View>(
        _ data: Data,
        content: @escaping (AnyChatMessage) -> Content
    ) where Data.Element: ChatMessageConvertible {
        self.init {
            ForEach(data) { (item: Data.Element) in
                let item: AnyChatMessage = item.__conversion()
                
                content(item)
                    .chatItem(id: item.id, role: item.role)
            }
        }
    }
    
    public init<Content: View>(
        _ data: Data,
        content: @escaping (Data.Element) -> Content
    ) {
        self.init {
            ForEach(data) { item in
                content(item)
            }
        }
    }
}

// MARK: - Modifiers

extension ChatMessageList {
    public func onEdit(
        perform fn: @escaping (Data.Element.ID, String) -> Void
    ) -> Self {
        then {
            $0._chatViewActions.onEdit = { fn($0.as(Data.Element.ID.self), $1.content) }
        }
    }

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
