//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX
import SwiftUIZ

struct _ChatItemCellActions: Initiable, ExpressibleByNilLiteral {
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
    
    init() {
        
    }
    
    init(nilLiteral: ()) {
        
    }
    
    init(from actions: _ChatViewActions, id: AnyChatItemIdentifier) {
        if let onEdit = actions.onEdit {
            self.onEdit = {
                onEdit(id, $0)
            }
        }
        
        if let onDelete = actions.onDelete {
            self.onDelete = {
                onDelete(id)
            }
        }
        
        if let onResend = actions.onResend {
            self.onResend = {
                onResend(id)
            }
        }
    }
}

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

// MARK: - Conformances

extension _ChatItemCellActions: MergeOperatable {
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

    @EnvironmentValue
    var _chatItemViewActions = _ChatItemCellActions()
}
