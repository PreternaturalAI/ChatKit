//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

/// A SwiftUI `List` based approach.
@frozen
public struct _ChatMessageListB<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ScrollViewReader { scrollView in
            _VariadicViewAdapter(content) { (content: _TypedVariadicView<Content>) in
                let lastItem: AnyChatItemIdentifier? = content.children.last?[trait: \._chatItemConfiguration]?.id
                
                makeList(content: content, scrollView: scrollView)
                    .modifier(
                        __LazyMessagesVStackScrollBehavior(
                            scrollView: scrollView,
                            lastItem: lastItem
                        )
                    )
            }
        }
        ._SwiftUIX_defaultScrollAnchor(.bottom)
    }
    
    private func makeList(
        content: _TypedVariadicView<Content>,
        scrollView: ScrollViewProxy
    ) -> some View {
        _AxisSizeReader(.horizontal) { size in
            List {
                _ForEachSubview(
                    enumerating: content,
                    trait: \._chatItemConfiguration
                ) { (index: Int, subview: _VariadicViewChildren.Subview, configuration: _ChatItemConfiguration) in
                    subview
                        .modifier(
                            __LazyMessagesVStackStackItem(
                                index: index,
                                id: configuration.id,
                                role: configuration.role.erasedAsAnyHashable,
                                isLast: index == content.children.count,
                                scrollView: scrollView,
                                containerWidth: size?.width
                            )
                        )
                        ._noListItemModification()
                }
            }
            .listStyle(.plain)
            ._noListItemModification()
        }
    }
}
