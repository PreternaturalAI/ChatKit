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
        CocoaScrollViewReader { proxy in
            _VariadicViewAdapter(content) { content in
                let lastItem: AnyChatItemIdentifier? = content.children.last?[trait: \_ViewTraitKeys._chatItemConfiguration]?.id

                CocoaList {
                    _ForEachSubview(enumerating: content, trait: \._chatItemConfiguration) { (index: Int, subview: _VariadicViewChildren.Subview, item: _ChatItemConfiguration) in
                        _ChatMessageRowContainer {
                            subview
                                .chatItem(id: item.id, role: item.role)
                                .padding(.horizontal, .small)
                                .modifier(
                                    __LazyMessagesVStackStackItem(
                                        index: index,
                                        id: item.id,
                                        role: item.role.erasedAsAnyHashable,
                                        isLast: nil,
                                        scrollView: nil,
                                        containerWidth: chatView?.containerSize?.width
                                    )
                                )
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
