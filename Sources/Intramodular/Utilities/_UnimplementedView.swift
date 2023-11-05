//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

struct _UnimplementedView: View {
    @usableFromInline
    let raiseIssue: () -> Void
    
    var body: some View {
        Image(systemName: .exclamationmarkTriangleFill)
            .font(.body)
            .foregroundColor(.yellow)
            .imageScale(.large)
            .border(Color.red)
            .onAppear(perform: raiseIssue)
    }
    
    init(file: StaticString = #file, line: UInt = #line) {
        raiseIssue = {
            runtimeIssue("This view is unimplemented.", file: file, line: line)
        }
    }
}
