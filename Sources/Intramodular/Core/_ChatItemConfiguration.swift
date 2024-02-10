//
// Copyright (c) Vatsal Manot
//


import Foundation

struct _ChatItemConfiguration: Initiable, ExpressibleByNilLiteral {
    var onEdit: ((AnyChatItemContent) -> Void)?
    var onDelete: (() -> Void)?
    var onResend: (() -> Void)?
    var decorations: [ChatItemDecorationPlacement: AnyView] = [:]
    
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
    
    init(id: AnyChatItemIdentifier, actions: _ChatViewActions) {
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

// MARK: - Conformances

extension _ChatItemConfiguration: MergeOperatable {
    public mutating func mergeInPlace(with other: Self) {
        self.onEdit = other.onEdit
        self.onDelete = other.onDelete
        self.onResend = other.onResend
        self.decorations = decorations.merging(other.decorations) { lhs, rhs in
            rhs
        }
    }
}

// MARK: - Auxiliary

extension EnvironmentValues {
    @EnvironmentValue
    var _chatItemConfiguration = _ChatItemConfiguration()
}
