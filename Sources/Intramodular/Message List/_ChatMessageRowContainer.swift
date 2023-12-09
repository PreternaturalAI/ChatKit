//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

struct _ChatMessageRowContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(width: .greedy)
    }
}
