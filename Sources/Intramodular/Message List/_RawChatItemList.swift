//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

@frozen
public struct _RawChatItemList<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ScrollViewReader { scrollView in
            _VariadicViewAdapter(content) { content in
                let lastItemID: AnyChatItemIdentifier? = content.children.last?[trait: \._chatItemConfiguration]?.id

                IntrinsicSizeReader { size in
                    List {
                        _ForEachSubview(
                            enumerating: content,
                            trait: \._chatItemConfiguration
                        ) { (index, subview, configuration) in
                            subview
                                .modifier(
                                    _ChatMessageStackStackItem(
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
                    ._SwiftUIX_defaultScrollAnchor(.bottom)
                }
                ._noListItemModification()
                .listStyle(.plain)
                .modifier(
                    _ChatMessageStackScrollBehavior(
                        scrollView: scrollView,
                        lastItem: lastItemID
                    )
                )
            }
        }
    }
}
