//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

public struct _ChatBubbleContainer<Content: View>: View {
    private let content: Content
    private let isSender: Bool

    public init(isSender: Bool, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isSender = isSender
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
