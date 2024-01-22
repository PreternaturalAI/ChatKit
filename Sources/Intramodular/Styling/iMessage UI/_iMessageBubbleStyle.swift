//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

@_spi(Internal)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct _iMessageBubbleStyle: ViewModifier {
    private let isSender: Bool
    private let isBorderless: Bool
    
    public init(isSender: Bool, isBorderless: Bool) {
        self.isSender = isSender
        self.isBorderless = isBorderless
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
                isBorderless ? .zero : EdgeInsets(
                    top: 4,
                    leading: 6,
                    bottom: 4,
                    trailing: 6
                )
            )
            .background(backgroundView)
            .modify(if: isBorderless) {
                $0.shadow(.regularMessageButtonStyle)
            }
            .accentColor(isSender ? Color.white : Color.accentColor)
            .foregroundStyle(foregroundStyle)
            .backgroundStyle(backgroundStyle)
    }
    
    private var backgroundView: some View {
        Group {
            Rectangle()
                .fill(backgroundStyle)
        }
        .mask {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                ._addMessageTail(location: isSender ? .trailing : .leading)
                .foregroundStyle(Color.black)
        }
        .drawingGroup(opaque: true)
        .modify(for: .visionOS) { content in
            if !isSender {
                content.opacity(0.75)
            } else {
                content
            }
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
