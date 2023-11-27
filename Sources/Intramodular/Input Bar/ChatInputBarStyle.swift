//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

public struct ChatInputBarConfiguration {
    public let textInput: AnyView?
    public let status: AnyView?
}

public protocol ChatInputBarStyle: DynamicProperty {
    associatedtype Body: View
    
    typealias Configuration = ChatInputBarConfiguration
    
    func makeBody(configuration: ChatInputBarConfiguration) -> Body
}

extension View {
    public func chatInputBarStyle<Style: ChatInputBarStyle>(
        _ style: Style
    ) -> some View {
        environment(\._chatInputBarStyle, style)
    }
}

extension EnvironmentValues {
    fileprivate struct ChatInputBarStyleKey: EnvironmentKey {
        static let defaultValue: (any ChatInputBarStyle) = FloatingChatInputBarStyle()
    }
    
    var _chatInputBarStyle: (any ChatInputBarStyle) {
        get {
            self[ChatInputBarStyleKey.self]
        } set {
            self[ChatInputBarStyleKey.self] = newValue
        }
    }
}

struct MessagesAppChatInputBarStyle: ChatInputBarStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: ChatInputBarConfiguration) -> some View {
        ZStack {
            makeTextInputContainer(content: configuration.textInput)
                .frame(minWidth: 44)

            if let status = configuration.status {
                status
            }
        }
        .padding(.small)
        .padding(.bottom, .small)
        .background(Material.ultraThin)
    }
    
    private func makeTextInputContainer(content: AnyView?) -> some View {
        Group {
            if let content = content {
                content.modifier(_TextViewConfiguration())
            } else {
                ZeroSizeView()
            }
        }
        .frame(width: .greedy)
        .visible(isEnabled)
    }
    
    private struct _TextViewConfiguration: ViewModifier {
        @Environment(\.isEnabled) var isEnabled
        
        @FocusState var isTextFieldFocused: Bool
        
        func body(content: Content) -> some View {
            content
                .frame(minWidth: 44, maxHeight: 512)
                .focused($isTextFieldFocused)
                .modify {
                    $0
                        .padding(.small)
                        .padding(.horizontal, .extraSmall)
                        .padding(.leading, .extraSmall)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(HierarchicalShapeStyle.tertiary))
                }
                .fixedSize(horizontal: false, vertical: true)
                .scrollDisabled(true)
                .font(.body)
                .onAppear {
                    focus()
                }
                .onTapGestureOnBackground {
                    focus()
                }
                .onChange(of: isEnabled) { isEnabled in
                    if isEnabled {
                        focus()
                    }
                }
        }
        
        private func focus() {
            withAnimation {
                isTextFieldFocused = true
            }
        }
    }
}

public struct FloatingChatInputBarStyle: ChatInputBarStyle {
    @Environment(\.isEnabled) var isEnabled
    
    public func makeBody(configuration: ChatInputBarConfiguration) -> some View {
        ZStack {
            Group {
                if let textInput = configuration.textInput {
                    textInput
                        .modifier(_LargeSpotlightLikeTextInputStyle())
                } else {
                    ZeroSizeView()
                }
            }
            .frame(width: .greedy)
            .visible(isEnabled)

            if let status = configuration.status {
                status.padding()
            }
        }
        .padding(.small)
        .padding(.bottom)
    }
}

#if os(iOS) || os(macOS) || os(tvOS)
struct _LargeSpotlightLikeTextInputStyle: ViewModifier {
    @FocusState var isTextFieldFocused: Bool

    func body(content: Content) -> some View {
        content
            .font(Font.title2.weight(.medium))
            .focused($isTextFieldFocused)
            .modify { view in
                view
                    .padding(.small)
                    .padding(.vertical, .extraSmall)
                    .padding(.horizontal, .extraSmall)
                    .padding(.leading, .extraSmall)
                    .background {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(HierarchicalShapeStyle.quaternary)
                            .shadow(radius: 4, x: 2, y: 2)
                            .onTapGesture {
                                isTextFieldFocused = true
                            }
                    }
                
            }
            .modify(for: .macOS) {
                $0.frame(minWidth: 88, maxWidth: 583)
            }
            .frame(maxHeight: 512)
            .fixedSize(horizontal: false, vertical: true)
            .scrollDisabled(true)
    }
}
#elseif os(visionOS)
struct _LargeSpotlightLikeTextInputStyle: ViewModifier {
    @FocusState var isTextFieldFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .font(Font.title2)
            .focused($isTextFieldFocused)
            .padding()
            .onTapGestureOnBackground {
                isTextFieldFocused = true
            }
            .frame(maxHeight: 512)
            .fixedSize(horizontal: false, vertical: true)
            .scrollDisabled(true)
    }
}
#endif

extension ChatInputBarStyle where Self == FloatingChatInputBarStyle {
    public static var floating: Self {
        .init()
    }
}
