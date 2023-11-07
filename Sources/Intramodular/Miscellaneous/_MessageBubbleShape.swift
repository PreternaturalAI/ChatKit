//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

public struct _MessageBubbleShape: Shape {
    public enum Direction: Sendable {
        case leading
        case trailing
    }
    
    public let direction: Direction
    
    public func path(in rect: CGRect) -> Path {
        return (direction == .leading) ? leadingPath(in: rect) : trailingPath(in: rect)
    }
    
    private func leadingPath(
        in rect: CGRect
    ) -> Path {
        let width = rect.width
        let height = rect.height
        
        let path = Path { path in
            path.move(to: .init(x: 21, y: height))
            path.addLine(to: .init(x: width - 15, y: height))
            path.addCurve(to: .init(x: width, y: height - 15), control1: .init(x: width - 8, y: height), control2: .init(x: width, y: height - 8))
            path.addLine(to: .init(x: width, y: 15))
            path.addCurve(to: .init(x: width - 15, y: 0), control1: .init(x: width, y: 8), control2: .init(x: width - 8, y: 0))
            path.addLine(to: .init(x: 21, y: 0))
            path.addCurve(to: .init(x: 5, y: 15), control1: .init(x: 12, y: 0), control2: .init(x: 5, y: 8))
            path.addLine(to: .init(x: 5, y: height - 10))
            path.addCurve(to: .init(x: 0, y: height), control1: .init(x: 5, y: height - 1), control2: .init(x: 0, y: height))
            path.addLine(to: .init(x: -1, y: height))
            path.addCurve(to: .init(x: 12, y: height - 4), control1: .init(x: 4, y: height + 1), control2: .init(x: 8, y: height - 1))
            path.addCurve(to: .init(x: 21, y: height), control1: .init(x: 15, y: height), control2: .init(x: 21, y: height))
        }
        
        return path
    }
    
    private func trailingPath(
        in rect: CGRect
    ) -> Path {
        let width = rect.width
        let height = rect.height
        
        let path = Path { path in
            path.move(to: .init(x: width - 21, y: height))
            path.addLine(to: .init(x: 15, y: height))
            path.addCurve(to: .init(x: 0, y: height - 15), control1: .init(x: 8, y: height), control2: .init(x: 0, y: height - 8))
            path.addLine(to: .init(x: 0, y: 15))
            path.addCurve(to: .init(x: 15, y: 0), control1: .init(x: 0, y: 8), control2: .init(x: 8, y: 0))
            path.addLine(to: .init(x: width - 21, y: 0))
            path.addCurve(to: .init(x: width - 5, y: 15), control1: .init(x: width - 12, y: 0), control2: .init(x: width - 5, y: 8))
            path.addLine(to: .init(x: width - 5, y: height - 12))
            path.addCurve(to: .init(x: width, y: height), control1: .init(x: width - 5, y: height - 1), control2: .init(x: width, y: height))
            path.addLine(to: .init(x: width + 1, y: height))
            path.addCurve(to: .init(x: width - 12, y: height - 4), control1: .init(x: width - 4, y: height + 1), control2: .init(x: width - 8, y: height - 1))
            path.addCurve(to: .init(x: width - 21, y: height), control1: .init(x: width - 15, y: height), control2: .init(x: width - 21, y: height))
        }
        
        return path
    }
}
