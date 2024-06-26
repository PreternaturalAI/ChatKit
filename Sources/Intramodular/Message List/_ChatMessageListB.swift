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
    
    private enum Subviews {
        case lastItem
    }
    
    public var body: some View {
        _VariadicViewAdapter(content) { (content: _SwiftUI_VariadicView<Content>) in
            let lastItem: AnyChatItemIdentifier? = content.children.last?[trait: \._chatItemConfiguration]?.id
            
            ScrollViewReader { scrollView in
                List {
                    _ForEachSubview(
                        enumerating: content,
                        trait: \._chatItemConfiguration,
                        id: \.id
                    ) { (index: Int, subview: _VariadicViewChildren.Subview, item: _ChatItemIdentity) in
                        _SwiftUI_UnaryViewAdaptor {
                            subview
                                .modifier(
                                    __LazyMessagesVStackStackItem(
                                        index: index,
                                        id: item.id,
                                        role: item.role.erasedAsAnyHashable,
                                        isLast: index == content.children.count,
                                        scrollView: scrollView
                                    )
                                )
                                .modifier(_ExpandAndAlignChatItem(item: item))
                        }
                        .modifier(_StipAllListItemStyling(insetsIncluded: false))
                        .id(item.id)
                    }
                }
                ._stripAllListOrListItemStyling()
                .modifier(_ChatMessageListB_ScrollBehavior(scrollView: scrollView, lastItem: lastItem))
            }
        }
    }
}

fileprivate struct _ChatMessageListB_ScrollBehavior: ViewModifier {
    let scrollView: ScrollViewProxy
    let lastItem: AnyChatItemIdentifier?
    
    func body(content: Content) -> some View {
        content
            .onAppearOnce {
                guard let lastItem else {
                    return
                }
                
                withoutAnimation(after: .milliseconds(200)) {
                    scrollView.scrollTo(lastItem, anchor: .bottom)
                    
                    withoutAnimation(after: .milliseconds(200)) {
                        scrollView.scrollTo(lastItem, anchor: .bottom)
                    }
                }
            }
            .withChangePublisher(for: lastItem) { lastItem in
                lastItem
                    .compactMap({ $0 })
                    .removeDuplicates()
                    .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
                    .sink { id in
                        withAnimation {
                            scrollView.scrollTo(id, anchor: .bottom)
                        }
                    }
            }
    }
}
