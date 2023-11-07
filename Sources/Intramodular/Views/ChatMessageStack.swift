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
        _IntrinsicGeometryValueReader(\.size.width) { width in
            Group {
                if let width = width, width.isNormal {
                    makeBody(width: width)
                } else {
                    XSpacer()
                }
            }
            .frame(minWidth: 128, maxWidth: .greatestFiniteMagnitude)
        }
        .id(_viewID)
    }
    
    private func makeBody(width: CGFloat) -> some View {
        ScrollViewReader { scrollView in
            _VariadicViewAdapter(content) { subviews in
                let lastID = subviews.children.last?[trait: \._chatItemConfiguration]?.id
                
                LazyVStack(spacing: 0) {
                    _ForEachSubview(
                        enumerating: subviews,
                        trait: \._chatItemConfiguration
                    ) { (index, subview, trait) in
                        if let role = trait.role as? ChatItemRoles.SenderRecipient {
                            subview
                                .contentShape(Rectangle())
                                .frame(maxWidth: min(width * 0.7, 800), alignment: role == .sender ? .trailing : .leading)
                                .frame(width: .greedy, alignment: role == .sender ? .trailing : .leading)
                                .id(trait.id)
                        }
                    }
                }
                .onAppear {
                    guard let lastID else {
                        return
                    }
                    
                    withAnimation(after: .milliseconds(200)) {
                        scrollView.scrollTo(lastID)
                    }
                }
                .onChange(of: subviews.isEmpty) { _ in
                    self._viewID = UUID()
                }
                .withChangePublisher(for: lastID) { lastID in
                    lastID.compactMap({ $0 })
                        .removeDuplicates()
                        .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
                        .sink { id in
                            withAnimation {
                                scrollView.scrollTo(id)
                            }
                        }
                }
            }
        }
    }
}
