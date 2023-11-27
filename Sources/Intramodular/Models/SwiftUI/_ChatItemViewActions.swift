//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX
import SwiftUIZ

struct _ChatItemViewActions: ExpressibleByNilLiteral {
    var onEdit: ((AnyChatItemContent) -> Void)?
    var onDelete: (() -> Void)?
    var onResend: (() -> Void)?
    
    init(
        onEdit: ((AnyChatItemContent) -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onResend: (() -> Void)? = nil
    ) {
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onResend = onResend
    }
    
    init(nilLiteral: ()) {
        
    }
}

// MARK: - Conformances

extension _ChatItemViewActions: MergeOperatable {
    public mutating func mergeInPlace(with other: Self) {
        self.onEdit = other.onEdit
        self.onDelete = other.onDelete
        self.onResend = other.onResend
    }
}

public struct ChatViewActions: MergeOperatable {
    var onEdit: ((AnyChatItemIdentifier, AnyChatItemContent) -> Void)?
    var onDelete: ((AnyChatItemIdentifier) -> Void)?
    var onResend: ((AnyChatItemIdentifier) -> Void)?
    
    public mutating func mergeInPlace(with other: Self) {
        self.onEdit = other.onEdit
        self.onDelete = other.onDelete
        self.onResend = other.onResend
    }
}

// MARK: - Auxiliary

extension EnvironmentValues {
    @EnvironmentValue
    var _chatItemViewActions: _ChatItemViewActions = nil
}
