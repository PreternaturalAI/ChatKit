//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

/*@_spi(Internal)
public struct _iMessageBubbleContainer<Content: View>: View {
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
            .modifier(_iMessageBubbleStyle(isSender: isSender, isBorderless: false))
    }
}
*/
