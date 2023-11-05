//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX

public protocol ChatItemRole: Hashable {
    
}

public enum ChatItemRoles {
    public enum SenderRecipient: ChatItemRole {
        case sender
        case recipient
        
        public var isIncoming: Bool {
            self == .recipient
        }
    }
}
