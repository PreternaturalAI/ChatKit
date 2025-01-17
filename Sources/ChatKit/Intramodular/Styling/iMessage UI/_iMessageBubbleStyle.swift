//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct _iMessageBubbleStyle: ViewModifier {
    private let isSender: Bool
    private let isBorderless: Bool
    private let error: AnyError?
    
    public init(
        isSender: Bool,
        isBorderless: Bool,
        error: AnyError?
    ) {
        self.isSender = isSender
        self.isBorderless = isBorderless
        self.error = error
    }
    
    private var foregroundStyle: AnyShapeStyle {
        isSender ? ForegroundStyle.regularMessageBubbleStyle.outgoing : ForegroundStyle.regularMessageBubbleStyle.incoming
    }
    
    private var backgroundStyle: AnyShapeStyle {
        isSender ? BackgroundStyle.regularMessageBubbleStyle.outgoing : BackgroundStyle.regularMessageBubbleStyle.incoming
    }
    
    public func body(content: Content) -> some View {
        HStack {
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
                .background {
                    backgroundView
                        .drawingGroup(opaque: false)
                }
                .shadow(isBorderless ? .regularMessageButtonStyle : nil)
                .accentColor(isSender ? Color.white : Color.accentColor)
                .foregroundStyle(foregroundStyle)
                .backgroundStyle(backgroundStyle)
            
            if error != nil {
                errorIndicator
            }
        }
        .animation(.default, value: error)
    }
    
    private var errorIndicator: some View {
        HoverReader { proxy in
            Button {
                
            } label: {
                Image(systemName: proxy.isHovering ? .arrowClockwise : .exclamationmarkCircle)
                    .font(.body.weight(.medium))
                    .imageScale(.large)
                    .foregroundColor(proxy.isHovering ? .orange : .red)
                    .transition(.opacity.combined(with: .scale).animation(.default))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
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
