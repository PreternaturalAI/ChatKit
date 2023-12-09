//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct MessageSendActivityDisclosure: View {
    public var body: some View {
        ProgressView()
            .controlSize(.small)
            .padding(.leading, .extraSmall)
            .modifier(_iMessageBubbleStyle(isSender: false, isBorderless: false))
            .frame(width: .greedy, alignment: .leading)
            .padding(.horizontal)
    }
    
    public init() {
        
    }
}
