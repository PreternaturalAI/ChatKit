//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow
import SwiftUIZ

struct _ChatItemConfiguration: Initiable, ExpressibleByNilLiteral {
    var onEdit: ((AnyChatItemContent) -> Void)?
    var onDelete: (() -> Void)?
    var onResend: (() -> Void)?
    var decorations: [ChatItemDecorationPlacement: AnyView] = [:]
    var activityPhase: ChatItemActivityPhase?
    
    init(
        onEdit: ((AnyChatItemContent) -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onResend: (() -> Void)? = nil,
        activityPhase: ChatItemActivityPhase?
    ) {
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onResend = onResend
        self.activityPhase = activityPhase
    }
    
    init() {
        
    }
    
    init(nilLiteral: ()) {
        
    }
}

extension _ChatItemConfiguration {
    init(id: AnyChatItemIdentifier, actions: _ChatViewActions) {
        self.init()
        
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
        self.onEdit = other.onEdit ?? self.onEdit
        self.onDelete = other.onDelete ?? self.onDelete
        self.onResend = other.onResend ?? self.onResend
        self.decorations = decorations.merging(other.decorations) { lhs, rhs in rhs }
        self.activityPhase = other.activityPhase ?? self.activityPhase
    }
}

// MARK: - Auxiliary

extension EnvironmentValues {
    @EnvironmentValue
    var _chatItemConfiguration = _ChatItemConfiguration()
}
