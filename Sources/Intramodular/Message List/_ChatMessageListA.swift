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
                    _ForEachSubview(content, trait: \._chatItemConfiguration) { (subview, item: _ChatItemConfiguration) in
                        subview
                            .padding(.small)
                            .padding(.horizontal, .extraSmall)
                            .frame(width: .greedy)
                            ._trait(\._chatItemConfiguration, item)
                    }
                }
                
                if chatView?.activityPhaseOfLastItem == .sending {
                    sendTaskDisclosure
                }
            }
            .padding(.vertical)
        }
        ._SwiftUIX_defaultScrollAnchor(.bottom)
        .background {
            _ChatViewBackground()
        }
        .onAppear {
            withoutAnimation(after: .seconds(1)) {
                showIndicators = true
            }
        }
    }
    
    private var sendTaskDisclosure: some View {
        ProgressView()
            .controlSize(.small)
            .padding(.leading, .extraSmall)
            .modifier(_iMessageBubbleStyle(isSender: false, isBorderless: false))
            .frame(width: .greedy, alignment: .leading)
            .padding(.horizontal)
    }
}
