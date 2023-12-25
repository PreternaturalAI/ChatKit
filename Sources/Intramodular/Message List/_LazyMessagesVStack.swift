//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX

public struct _LazyMessagesVStack<Content: View>: View {
    @Environment(\._chatViewPreferences) var chatView
    
    private let content: Content
    
    /// A hack used to reset the view's identity.
    @State private var _viewID = UUID()
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ScrollViewReader { scrollView in
            if chatView != nil {
                makeBody(scrollView: scrollView)
                    .modify(for: .visionOS) { content in
                        content
                            .padding(.horizontal)
                            .padding()
                    }
                    .frame(minWidth: 128, maxWidth: .infinity)
            }
        }
        .id(_viewID)
    }
    
    private func makeBody(
        scrollView: ScrollViewProxy
    ) -> some View {
        _VariadicViewAdapter<Content, _>(content) { subviews in
            let lastID = subviews.children.last?[trait: \._chatItemConfiguration]?.id
            
            if subviews.isEmpty {
                contentUnavailableView
            }
            
            LazyVStack(spacing: 0) {
                _ForEachSubview(
                    enumerating: subviews,
                    trait: \._chatItemConfiguration
                ) { (index, subview, configuration) in
                    subview
                        .modifier(
                            __LazyMessagesVStackStackItem(
                                index: index,
                                id: configuration.id,
                                role: configuration.role.erasedAsAnyHashable,
                                isLast: index == subviews.children.count,
                                scrollView: scrollView,
                                containerWidth: chatView?.containerSize?.width
                            )
                        )
                }
            }
            .modifier(
                __LazyMessagesVStackScrollBehavior(
                    scrollView: scrollView,
                    lastItem: lastID
                )
            )
            .onChange(of: subviews.isEmpty) { _ in
                self._viewID = UUID()
            }
        }
    }
    
    @ViewBuilder
    private var contentUnavailableView: some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            ContentUnavailableView {
                Image(systemName: .messageFill)
                    .font(.largeTitle)
            } description: {
                Text("No Messages")
                    .font(.title)
            }
            .padding(.extraLarge)
        }
    }
}

struct __LazyMessagesVStackScrollBehavior: ViewModifier {
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

struct __LazyMessagesVStackStackItem: Identifiable, ViewModifier {
    let index: Int?
    let id: AnyChatItemIdentifier
    let role: AnyHashable
    let isLast: Bool?
    let scrollView: ScrollViewProxy?
    let containerWidth: CGFloat?
    
    func body(content: Content) -> some View {
        let role = role.base as! ChatItemRoles.SenderRecipient
        
        content
            .contentShape(Rectangle())
            .onChangeOfFrame { _ in
                scrollView?.scrollTo(id, anchor: .bottom)
            }
            .frame(
                maxWidth: min((containerWidth ?? (800 / 0.7)) * 0.7, 800),
                alignment: role == .sender ? .trailing : .leading
            )
            .frame(
                width: .greedy,
                alignment: role == .sender ? .trailing : .leading
            )
            .padding(.top, index == 0 ? 12 : 0)
            .padding(.bottom, 4)
    }
}
