//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX

public struct ChatMessageStack<Content: View>: View {
    private let content: Content
    
    /// A hack used to reset the view's identity.
    @State private var _viewID = UUID()
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        _IntrinsicGeometryValueReader(\.size.width) { containerWidth in
            ScrollViewReader { scrollView in
                Group {
                    if let containerWidth = containerWidth, containerWidth.isNormal {
                        makeBody(
                            containerWidth: containerWidth,
                            scrollView: scrollView
                        )
                    } else {
                        XSpacer()
                    }
                }
                .frame(minWidth: 128, maxWidth: .greatestFiniteMagnitude)
            }
        }
        .id(_viewID)
    }
    
    private func makeBody(
        containerWidth: CGFloat,
        scrollView: ScrollViewProxy
    ) -> some View {
        _VariadicViewAdapter<Content, _>(content) { subviews in
            let lastID = subviews.children.last?[trait: \._chatItemConfiguration]?.id
                        
            LazyVStack(spacing: 0) {
                _ForEachSubview(
                    enumerating: subviews,
                    trait: \._chatItemConfiguration
                ) { (index, subview, configuration) in
                    subview
                        .modifier(
                            _ChatMessageStackStackItem(
                                index: index,
                                id: configuration.id,
                                role: configuration.role.erasedAsAnyHashable,
                                isLast: index == subviews.children.count,
                                scrollView: scrollView,
                                containerWidth: containerWidth
                            )
                        )
                }           
            }
            .modifier(
                _ChatMessageStackScrollBehavior(
                    scrollView: scrollView,
                    lastItem: lastID
                )
            )
            .onChange(of: subviews.isEmpty) { _ in
                self._viewID = UUID()
            }
            .animation(.default, value: subviews.children.count)
        }
    }
}

private struct _ChatMessageStackScrollBehavior: ViewModifier {
    let scrollView: ScrollViewProxy
    let lastItem: AnyChatItemIdentifier?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard let lastItem else {
                    return
                }
                
                withAnimation(after: .milliseconds(200)) {
                    scrollView.scrollTo(lastItem, anchor: .bottom)
                }
            }
            .withChangePublisher(for: lastItem) { lastItem in
                lastItem.compactMap({ $0 })
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

private struct _ChatMessageStackStackItem: Identifiable, ViewModifier {
    let index: Int
    let id: AnyChatItemIdentifier
    let role: AnyHashable
    let isLast: Bool
    let scrollView: ScrollViewProxy
    let containerWidth: CGFloat
    
    func body(content: Content) -> some View {
        let role = role.base as! ChatItemRoles.SenderRecipient
        
        IntrinsicSizeReader { size in
            content
                .contentShape(Rectangle())
                .frame(
                    maxWidth: min(
                        containerWidth * 0.7,
                        800
                    ),
                    alignment: role == .sender ? .trailing : .leading
                )
                .frame(
                    width: .greedy,
                    alignment: role == .sender ? .trailing : .leading
                )
                .onChange(of: size) { [size] newSize in
                    if size.height < newSize.height {
                        scrollView.scrollTo(id, anchor: .bottom)
                    }
                }
        }
    }
}
