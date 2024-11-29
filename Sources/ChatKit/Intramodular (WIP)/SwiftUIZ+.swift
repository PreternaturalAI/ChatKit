//
// Copyright (c) Vatsal Manot
//

import SwiftUIZ

extension View {
    @ViewBuilder
    public func _formStackByAdding<Content: View>(
        _ axis: Axis,
        _ alignment: Alignment,
        @ViewBuilder content: () -> Content
    ) -> some View {
        if axis == .horizontal {
            if alignment == .leading {
                HStack {
                    content()
                    self
                }
            } else if alignment == .trailing {
                HStack {
                    self
                    content()
                }
            }
        } else if axis == .horizontal {
            if alignment == .top {
                VStack {
                    content()
                    self
                }
            } else if alignment == .bottom {
                VStack {
                    self
                    content()
                }
            }
        } else {
            _UnimplementedView()
        }
    }
}
