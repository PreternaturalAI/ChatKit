//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

/// A SwiftUIX `ScrollView` + `LazyVStack` based approach.
public struct _ChatMessageListA<Content: View>: View {
    @Environment(\._chatViewPreferences) private var chatView
    
    private let content: Content
    
    @State private var showIndicators: Bool = false
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ScrollView(showsIndicators: showIndicators) {
            _VariadicViewAdapter(content) { content in
                _LazyMessagesVStack {
                    _ForEachSubview(content, trait: \._chatItemConfiguration) { (subview, item: _ChatItemIdentity) in
                        subview
                            .padding(.small)
                            .padding(.horizontal, .extraSmall)
                            .modifier(_ExpandAndAlignChatItem(item: item))
                            ._trait(\._chatItemConfiguration, item)
                    }
                    
                    if chatView?.activityPhaseOfLastItem == .sending {
                        ChatItemCell(item: AnyPlaceholderChatItem())
                            .modifier(
                                _ExpandAndAlignChatItem(
                                    item: .init(
                                        id: AnyPlaceholderChatItem.id,
                                        role: ChatItemRoles.SenderRecipient.recipient
                                    )
                                )
                            )
                    }
                }
            }
            .padding(.vertical)
        }
        ._SwiftUIX_defaultScrollAnchor(.bottom)
        .onAppear {
            withoutAnimation(after: .seconds(1)) {
                showIndicators = true
            }
        }
    }
}
