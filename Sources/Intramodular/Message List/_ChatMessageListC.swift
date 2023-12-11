//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

/// A SwiftUIX `CocoaList` based approach.
public struct _ChatMessageListC<Content: View>: View {
    @Environment(\._chatViewPreferences) private var chatView
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        CocoaList {
            _VariadicViewAdapter(content) { content in
                _ForEachSubview(content, trait: \._chatItemConfiguration) { subview, item in
                    _ChatMessageRowContainer {
                        withEnvironmentValue(\._chatViewActions) { actions in
                            subview
                                .chatItem(id: item.id, role: item.role)
                                .environment(\._chatItemViewActions, .init(from: actions, id: item.id))
                                .cocoaListItem(id: item.id)
                                .modifier(
                                    __LazyMessagesVStackStackItem(
                                        index: nil,
                                        id: item.id,
                                        role: item.role.erasedAsAnyHashable,
                                        isLast: nil,
                                        scrollView: nil,
                                        containerWidth: chatView?.containerSize?.width
                                    )
                                )
                                .padding(.small)
                        }
                    }
                }
            }
        }
        ._SwiftUIX_defaultScrollAnchor(.bottom)
    }
}
