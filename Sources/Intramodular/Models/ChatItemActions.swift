//
// Copyright (c) Vatsal Manot
//

import SwiftUI

struct ChatItemActions: ExpressibleByNilLiteral {
    var onEdit: ((String) -> Void)?
    var onDelete: (() -> Void)?
    var onResend: (() -> Void)?
    
    init(
        onEdit: ((String) -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onResend: (() -> Void)? = nil
    ) {
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onResend = onResend
    }
    
    init(nilLiteral: ()) {
        
    }
    
    func updating(with other: Self) -> Self {
        var result = self
        
        result.onEdit = other.onEdit
        result.onDelete = other.onDelete
        result.onResend = other.onResend
        
        return result
    }
}

extension EnvironmentValues {
    struct ChatItemActionsKey: EnvironmentKey {
        static var defaultValue: ChatItemActions = nil
    }
    
    var _chatItemActions: ChatItemActions {
        get {
            self[ChatItemActionsKey.self]
        } set {
            self[ChatItemActionsKey.self] = newValue
        }
    }
}

