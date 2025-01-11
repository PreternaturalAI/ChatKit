//
// Copyright (c) Vatsal Manot
//

import Swallow
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
    
    @State private var lastItem: AnyChatItemIdentifier?
    
    public var body: some View {
        ScrollViewReader { scrollView in
            List {
                _VariadicViewAdapter(content) { (content: _SwiftUI_VariadicView<Content>) in
                    PerformAction {
                        let lastItem = content.children.last?[trait: \._chatItemTraitValue]?.id
                        
                        if self.lastItem != lastItem {
                            withoutAnimation {
                                self.lastItem = lastItem
                            }
                        }
                    }
                    
                    _ForEachSubview(
                        enumerating: content,
                        trait: \._chatItemTraitValue
                    ) { (index: Int, subview: _VariadicViewChildren.Subview, item: _ChatItemTraitValue) in
                        _ChatMessageRowContainer(
                            id: item.id,
                            offset: _ElementOffsetInParentCollection(offset: index, in: 0..<content.children.count)
                        ) {
                            subview
                        }
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
                        .modifier(_StipAllListItemStyling(insetsIncluded: false))
                        .id(item.id)
                    }
                }
                ._stripAllListOrListItemStyling()
                .modifier(_ChatMessageListB_ScrollBehavior(scrollView: scrollView, lastItem: $lastItem))
            }
        }
        ._SwiftUIX_defaultScrollAnchor(.bottom)
    }
}

fileprivate struct _ChatMessageListB_ScrollBehavior: ViewModifier {
    let scrollView: ScrollViewProxy
    
    @Binding var lastItem: AnyChatItemIdentifier?
    
    @ViewStorage var hasScrolledOnce: Bool = false
    
    func body(content: Content) -> some View {
        content
            .onAppearOnce {
                scrollTo(lastItem)
            }
            .withChangePublisher(for: lastItem) { lastItem in
                lastItem
                    .compactMap({ $0 })
                    .removeDuplicates()
                    .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
                    .sink { (id: AnyChatItemIdentifier) in
                        scrollTo(id)
                    }
            }
    }
    
    private func scrollTo(_ item: AnyChatItemIdentifier?) {
        guard let item: AnyChatItemIdentifier = item ?? self.lastItem else {
            return
        }
        
        scrollView.scrollTo(lastItem, anchor: .bottom)
        
        if !hasScrolledOnce {
            withoutAnimation(after: .milliseconds(200)) {
                scrollView.scrollTo(item, anchor: .bottom)
                                
                hasScrolledOnce = true
            }
            
            withoutAnimation(after: .milliseconds(250)) {
                scrollView.scrollTo(item, anchor: .bottom)
            }
        }
    }
}
