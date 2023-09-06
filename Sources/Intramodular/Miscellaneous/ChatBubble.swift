//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

public struct ChatBubble<Content: View>: View {
    private let isSender: Bool
    private let content: Content
    
    public init(isSender: Bool, @ViewBuilder content: () -> Content) {
        self.isSender = isSender
        self.content = content()
    }
    
    public var body: some View {
        content
            .font(.body)
            .foregroundStyle(.primary)
            .padding(isSender ? .trailing : .leading, .extraSmall)
            .frame(minWidth: 44, minHeight: 10)
            .modifier(RegularMessageBubbleStyle(isSender: isSender, contentExtendsToEdges: false))
    }
}
