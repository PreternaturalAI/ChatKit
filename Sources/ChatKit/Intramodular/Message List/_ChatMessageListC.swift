//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX
import SwiftUIZ

/// A SwiftUIX `CocoaList` based approach.
public struct _ChatMessageListC<Content: View>: View {
    @Environment(\._chatViewPreferences) private var chatView: _ChatViewPreferences
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        CocoaScrollViewReader { proxy in
            _VariadicViewAdapter(content) { (content: _SwiftUI_VariadicView<Content>) in
                let lastItem: AnyChatItemIdentifier? = content.children.last?[trait: \._chatItemTraitValue]?.id

                CocoaList {
                    _ForEachSubview(
                        enumerating: content,
                        trait: \._chatItemTraitValue
                    ) { (index: Int, subview: _VariadicViewChildren.Subview, item: _ChatItemTraitValue) in
                        _ChatMessageRowContainer(
                            id: item.id,
                            offset: _ElementOffsetInParentCollection(offset: index, in: 0..<content.children.count)
                        ) {
                            subview
                                .chatItem(id: item.id, role: item.role)
                                .padding(.horizontal, .small)
                                .modifier(
                                    __LazyMessagesVStackStackItem(
                                        index: index,
                                        id: item.id,
                                        role: item.role.erasedAsAnyHashable,
                                        isLast: nil,
                                        scrollView: nil
                                    )
                                )
                                .modifier(_ExpandAndAlignChatItem(item: item))
                        }
                    }
                }
                .modifier(_ChatMessageListC_ScrollBehavior(scrollView: proxy, lastItem: lastItem))
            }
            ._SwiftUIX_defaultScrollAnchor(.bottom)
        }
    }
}

fileprivate struct _ChatMessageListC_ScrollBehavior: ViewModifier {
    let scrollView: CocoaScrollViewProxy
    let lastItem: AnyChatItemIdentifier?
    
    func body(content: Content) -> some View {
        content
            .initialContentAlignment(.bottom)
            .withChangePublisher(for: lastItem) { lastItem in
                lastItem
                    .compactMap({ $0 })
                    .removeDuplicates()
                    .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
                    .sink { _ in
                        scrollView.scrollTo(.bottom)
                    }
            }
    }
}
