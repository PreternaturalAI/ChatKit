//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct RegularMessageBubbleStyle: ViewModifier {
    private let isSender: Bool
    private let contentExtendsToEdges: Bool
    
    public init(isSender: Bool, contentExtendsToEdges: Bool) {
        self.isSender = isSender
        self.contentExtendsToEdges = contentExtendsToEdges
    }
    
    private var foregroundStyle: AnyShapeStyle {
        isSender ? ForegroundStyle.regularMessageBubbleStyle.outgoing : ForegroundStyle.regularMessageBubbleStyle.incoming
    }
    
    private var backgroundStyle: AnyShapeStyle {
        isSender ? BackgroundStyle.regularMessageBubbleStyle.outgoing : BackgroundStyle.regularMessageBubbleStyle.incoming
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(.extraSmall)
            .padding(
                contentExtendsToEdges ? .zero : EdgeInsets(
                    top: 4,
                    leading: 6,
                    bottom: 4,
                    trailing: 6
                )
            )
            .background {
                Rectangle()
                    .fill(backgroundStyle)
                    .mask {
                        RoundedRectangle(cornerRadius: 18)
                            ._messageTail(location: isSender ? .trailing : .leading)
                            .foregroundStyle(Color.black)
                    }
                    .drawingGroup()
            }
            .modify(if: contentExtendsToEdges) {
                $0.shadow(.regularMessageButtonStyle)
            }
            .accentColor(isSender ? Color.white : Color.accentColor)
            .foregroundStyle(foregroundStyle)
            .backgroundStyle(backgroundStyle)
            .frame(minWidth: 44, minHeight: 10)
    }
    
    /// Unused.
    private var shape: AnyShape {
        if contentExtendsToEdges {
            return AnyShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else {
            return AnyShape(_MessageBubbleShape(direction: isSender ? .trailing : .leading))
        }
    }
}

// MARK: - Auxiliary

extension BackgroundStyle {
    fileprivate static let regularMessageBubbleStyle = (
        outgoing: AnyShapeStyle(Color.systemBlue),
        incoming: AnyShapeStyle(HierarchicalShapeStyle.quaternary)
    )
}

extension ForegroundStyle {
    fileprivate static let regularMessageBubbleStyle = (
        outgoing: AnyShapeStyle(Color.white),
        incoming: AnyShapeStyle(Color.label)
    )
}

extension _ViewShadowStyle {
    fileprivate static let regularMessageButtonStyle = Self.drop(
        color: Color.black.opacity(0.1),
        radius: 5
    )
}