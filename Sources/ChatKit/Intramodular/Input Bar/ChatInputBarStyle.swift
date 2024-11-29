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
