//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct ChatViewProperties: ExpressibleByNilLiteral {
    var messageDeliveryState: MessageDeliveryState?
    var interrupt: (() -> Void)?
    
    public init(nilLiteral: ()) {
        self.messageDeliveryState = nil
    }
}

public struct ChatViewConfiguration {
    public fileprivate(set) var selection: ChatItemSelection?
    
    fileprivate init() {
        
    }
}

extension ChatViewConfiguration {
    struct _PreferenceKey: PreferenceKey {
        static let defaultValue = ChatViewConfiguration()
        
        static func reduce(
            value: inout ChatViewConfiguration,
            nextValue: () -> ChatViewConfiguration
        ) {
            let next = nextValue()
            
            value.selection = next.selection ?? value.selection
        }
    }
}

// MARK: - Auxiliary -

extension EnvironmentValues {
    struct ChatViewKey: EnvironmentKey {
        static let defaultValue: ChatViewProperties? = nil
    }
    
    public var _chatContainer: ChatViewProperties? {
        get {
            self[ChatViewKey.self]
        } set {
            self[ChatViewKey.self] = newValue
        }
    }
}
