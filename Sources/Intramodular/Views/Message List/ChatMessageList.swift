//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

public struct _ChatMessageListItemAttributes: Hashable, Sendable {
    public let isSender: Bool
    
    public init(isSender: Bool) {
        self.isSender = isSender
    }
}

public struct ChatMessageList<Data: RandomAccessCollection, Content: View>: View where Data.Element: Equatable & Identifiable {
    public typealias Item = Data.Element
    
    let data: Data
    let content: (Self, Item) -> Content
    let itemAttributes: (Item) -> _ChatMessageListItemAttributes?
    
    var onResend: ((Item.ID) -> Void)?
    var onDelete: ((Item.ID) -> Void)?
    
    var messageDeliveryState: MessageDeliveryState? = nil
    
    @State private var didScroll: Bool = false
    
    init(
        _ data: Data,
        @ViewBuilder content: @escaping (Self, Item) -> Content,
        attributes: @escaping (Item) -> _ChatMessageListItemAttributes? = { _ in nil }
    ) {
        self.data = data
        self.content = content
        self.itemAttributes = attributes
    }

    public init(
        _ data: Data,
        @ViewBuilder content: @escaping (Item) -> Content,
        attributes: @escaping (Item) -> _ChatMessageListItemAttributes? = { _ in nil }
    ) {
        self.data = data
        self.content = { content($1) }
        self.itemAttributes = attributes
    }
    
    public init(
        _ data: Data
    ) where Data.Element: ChatMessageConvertible, Content == AnyView {
        self.init(
            data,
            content: { _list, item in
                let message = item.toChatMessage()
                
                ChatMessageView(message: message)
                    .onDelete(perform: _list.onDelete.map { onDelete in
                        { onDelete(item.id) }
                    })
                    .onResend(perform: _list.onResend.map { onResend in
                        { onResend(item.id) }
                    })
                    .chatMessage(id: message.id, role: message.isSender ? .sender : .recipient)
                    .eraseToAnyView()
            },
            attributes: {
                _ChatMessageListItemAttributes(isSender: $0.toChatMessage().isSender)
            }
        )
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            scrollView
                .visible(didScroll)
                .background(DefaultChatViewBackground())
                .task {
                    didAppear(scrollView: proxy)
                }
                .onChange(of: data.last) { _ in
                    if let last = data.last {
                        withAnimation(after: .milliseconds(50)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
        }
    }
    
    private func didAppear(scrollView: ScrollViewProxy) {
        if let last = data.last {
            scrollView.scrollTo(last.id, anchor: .bottom)
            
            withoutAnimation(after: .milliseconds(50)) {
                scrollView.scrollTo(last.id, anchor: .bottom)
                
                withAnimation(.default) {
                    didScroll = true
                }
            }
        } else {
            didScroll = true
        }
    }
    
    private var scrollView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ChatMessageStack {
                    ForEach(data) { item in
                        if let attributes = itemAttributes(item) {
                            content(self, item)
                                .chatMessage(
                                    id: item.id,
                                    role: attributes.isSender ? .sender : .recipient
                                )
                        } else {
                            content(self, item)
                        }
                    }
                    .padding(.small)
                }
                
                if messageDeliveryState == .sending {
                    sendTaskDisclosure
                }
            }
            .padding(.vertical)
        }
    }
    
    private var sendTaskDisclosure: some View {
        ProgressView()
            .controlSize(.small)
            .padding(.leading, .extraSmall)
            .modifier(RegularMessageBubbleStyle(isSender: false, contentExtendsToEdges: false))
            .frame(width: .greedy, alignment: .leading)
            .padding(.horizontal)
    }
}

extension ChatMessageList {
    public func onDelete(
        perform fn: @escaping (Item.ID) -> Void
    ) -> Self {
        then {
            $0.onDelete = fn
        }
    }
    
    public func onResend(
        perform fn: @escaping (Item.ID) -> Void
    ) -> Self {
        then {
            $0.onResend = fn
        }
    }
}
