//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

fileprivate struct _iMessageTailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let arrowExtensionPercent: CGFloat = 0.25
        let arrowExtensionAmount = rect.width * arrowExtensionPercent
        
        path.move(
            to: CGPoint(
                x: rect.minX,
                y: rect.minY
            )
        )
        
        path.addArc(
            center: CGPoint(
                x: rect.width + arrowExtensionAmount,
                y: rect.minY
            ),
            radius: rect.width,
            startAngle: .degrees(180),
            endAngle: .degrees(86),
            clockwise: true
        )
     
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control1: CGPoint(
                x: rect.maxX + (arrowExtensionAmount * 0.8),
                y: rect.maxY * 0.95
            ),
            control2: CGPoint(
                x: rect.maxX,
                y: rect.maxY * 0.75
            )
        )
        
        path.addLine(
            to: CGPoint(x: rect.maxX, y: rect.minY)
        )
        
        path.closeSubpath()
        
        return path
    }
}

fileprivate struct _MessageTailViewModifier: ViewModifier {
    let visible: Bool
    let zAlignment: Alignment
    let size: CGFloat
    let rotationAngle: Angle
    let axis: (x: CGFloat, y: CGFloat, z: CGFloat)
    
    func body(content: Content) -> some View {
        ZStack(alignment: zAlignment) {
            if visible {
                _iMessageTailShape()
                    .rotation3DEffect(rotationAngle, axis: axis)
                    .frame(width: size, height: size)
            }
            
            content
        }
        .padding(zAlignment.horizontal == .leading ? .leading : .trailing, .extraSmall)
    }
    
    init(
        visible: Bool,
        location: HorizontalAlignment,
        size: CGFloat = 18
    ) {
        self.visible = visible
        self.zAlignment = Alignment(horizontal: location, vertical: .bottom)
        self.size = size
        
        switch location {
            case .leading:
                self.rotationAngle = .degrees(180)
                self.axis = (x: 0, y: 1, z: 0)
            default:
                self.rotationAngle = .degrees(0)
                self.axis = (x: 0, y: 0, z: 0)
        }
    }
}

extension View {
    func _addMessageTail(
        _ visible: Bool = true,
        location: HorizontalAlignment,
        size: CGFloat = 18
    ) -> some View {
        self.modifier(
            _MessageTailViewModifier(
                visible: visible,
                location: location,
                size: size
            )
        )
    }
}
