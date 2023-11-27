//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

public struct ChatMessageList<Data: RandomAccessCollection, Content: View>: View where Data.Element: Equatable & Identifiable {
    public typealias Item = Data.Element
    
    @Environment(\._chatViewPreferences) var _chatViewPreferences

    let data: Data
    let content: (Self, Item) -> Content
    let itemAttributes: (Item) -> _ChatMessageListItemAttributes?
    
    var onResend: ((Item.ID) -> Void)?
    var onDelete: ((Item.ID) -> Void)?
    
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
                let message = item.__conversion()
                
                _ChatItemContentView(message: message)
                    .onDelete(perform: _list.onDelete.map { onDelete in
                        { onDelete(item.id) }
                    })
                    .onResend(perform: _list.onResend.map { onResend in
                        { onResend(item.id) }
                    })
                    .chatMessage(id: message.id, role: try! message.isSender ? .sender : .recipient)
                    .eraseToAnyView()
            },
            attributes: {
                _ChatMessageListItemAttributes(isSender: try! $0.__conversion().isSender)
            }
        )
    }
    
    public var body: some View {
        ScrollView {
            scrollContent
        }
        ._SwiftUIX_defaultScrollAnchor(.bottom)
        .background {
            DefaultChatViewBackground()
        }
    }
    
    private var scrollContent: some View {
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
            ._noListItemModification()
            
            if _chatViewPreferences?.messageDeliveryState == .sending {
                sendTaskDisclosure
            }
        }
        .padding(.vertical)
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

