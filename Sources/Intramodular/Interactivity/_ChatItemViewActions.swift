//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX
import SwiftUIZ

public struct _ChatViewActions: Initiable, MergeOperatable {
    var onEdit: ((AnyChatItemIdentifier, AnyChatItemContent) -> Void)?
    var onDelete: ((AnyChatItemIdentifier) -> Void)?
    var onResend: ((AnyChatItemIdentifier) -> Void)?
    
    public init() {
        
    }
    
    public mutating func mergeInPlace(with other: Self) {
        self.onEdit = other.onEdit
        self.onDelete = other.onDelete
        self.onResend = other.onResend
    }
}

// MARK: - Auxiliary

extension EnvironmentValues {
    @EnvironmentValue
    var _chatViewActions = _ChatViewActions()
}
