//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX
import SwiftUIZ

@_spi(Internal)
public struct _ChatViewInteractions: MergeOperatable {
    public enum Selection {
        case single(ChatItemSelection)
        case multiple(ChatItemMultipleSelection)
    }
    
    public var selection: Selection?
    
    public init(nilLiteral: ()) {
        
    }
    
    public mutating func mergeInPlace(with other: Self) {
        self.selection = other.selection
    }
}

public struct _ChatViewPreferences: Equatable, MergeOperatable {
    var itemActivities: [AnyChatItemIdentifier: _ChatItemActivity] = [:]
    var itemActivityPhaseByItem: [AnyChatItemIdentifier: ChatItemActivityPhase] = [:]
    var onInterrupt: Action?
    var activityPhaseOfLastItem: ChatItemActivityPhase?

    public mutating func mergeInPlace(with other: Self) {
        self.itemActivities.merge(other.itemActivities, uniquingKeysWith: { lhs, rhs in rhs })
        self.itemActivityPhaseByItem.merge(other.itemActivityPhaseByItem, uniquingKeysWith: { lhs, rhs in rhs })
        self.onInterrupt ??= other.onInterrupt
        self.activityPhaseOfLastItem ??= other.activityPhaseOfLastItem
    }
}

// MARK: - Auxiliary -

extension _ChatViewPreferences {
    struct _PreferenceKey: PreferenceKey {
        typealias Value = _ChatViewPreferences
        
        static let defaultValue = _ChatViewPreferences()
    }
}

extension EnvironmentValues {
    @EnvironmentValue
    public var _chatViewPreferences: _ChatViewPreferences = .init()
}
