//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX
import SwiftUIZ

public struct _ChatViewPreferences: Equatable {
    var itemActivities: [AnyChatItemIdentifier: _ChatItemActivity] = [:]
    var activityPhaseOfLastItem: ChatItemActivityPhase?
    var interrupt: Action?
    var containerSize: CGSize?
}

// MARK: - Conformances

extension _ChatViewPreferences: MergeOperatable {
    public mutating func mergeInPlace(with other: Self) {
        self.itemActivities.merge(other.itemActivities, uniquingKeysWith: { lhs, rhs in rhs })
        self.activityPhaseOfLastItem ??= other.activityPhaseOfLastItem
        self.interrupt ??= other.interrupt
        self.containerSize ??= other.containerSize
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
    public var _chatViewPreferences: _ChatViewPreferences?
}
