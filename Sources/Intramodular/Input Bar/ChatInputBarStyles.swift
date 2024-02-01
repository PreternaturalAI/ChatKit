//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

public struct MessagesAppChatInputBarStyle: ChatInputBarStyle {
    @Environment(\.isEnabled) var isEnabled
    
    public func makeBody(configuration: ChatInputBarConfiguration) -> some View {
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
                ._onChange(of: isEnabled) { isEnabled in
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


extension ChatInputBarStyle where Self == MessagesAppChatInputBarStyle {
    public static var messages: Self {
        .init()
    }
}

public struct FloatingChatInputBarStyle: ChatInputBarStyle {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.userInterfaceIdiom) var userInterfaceIdiom

    public func makeBody(configuration: ChatInputBarConfiguration) -> some View {
        UnaryViewAdaptor {
            ZStack {
                Group {
                    if let textInput = configuration.textInput {
                        textInput
                            .modifier(_LargeSpotlightLikeTextInputStyle())
                            .modifier(_DefineTextInputShape())
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
        }
        .padding(.small)
        .padding(userInterfaceIdiom == .vision ? .top : .bottom)
        .padding(.bottom)
    }
}

#if os(visionOS)
extension FloatingChatInputBarStyle {
    fileprivate struct _DefineTextInputShape: ViewModifier {
        func body(content: Content) -> some View {
            content
                .compositingGroup()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 16))
                ._geometryGroup(.if(.available))
                .hoverEffect()
        }
    }
}
#else
extension FloatingChatInputBarStyle {
    fileprivate struct _DefineTextInputShape: ViewModifier {
        func body(content: Content) -> some View {
            content
        }
    }
}
#endif

extension ChatInputBarStyle where Self == FloatingChatInputBarStyle {
    public static var floating: Self {
        .init()
    }
}

#if os(iOS) || os(macOS) || os(tvOS)
fileprivate struct _LargeSpotlightLikeTextInputStyle: ViewModifier {
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
fileprivate struct _LargeSpotlightLikeTextInputStyle: ViewModifier {
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
