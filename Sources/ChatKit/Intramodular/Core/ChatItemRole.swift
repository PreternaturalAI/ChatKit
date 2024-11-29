//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX

public protocol ChatItemRoleConvertible: Hashable {
    func __conversion() -> any ChatItemRole
}

public protocol ChatItemRole: Hashable {
    func invertRole() throws -> Self
}

public enum ChatItemRoles {
    public enum SenderRecipient: ChatItemRole {
        case sender
        case recipient
        
        public var isIncoming: Bool {
            self == .recipient
        }
    
        public func invertRole() throws -> Self {
            switch self {
                case .sender:
                    return .recipient
                case .recipient:
                    return .sender
            }
        }
    }
}
