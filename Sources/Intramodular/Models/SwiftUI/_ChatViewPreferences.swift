//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX
import SwiftUIZ

public struct _ChatViewPreferences: Hashable {
    var itemActivities: [AnyChatItemIdentifier: _ChatItemActivity] = [:]
    var messageDeliveryState: MessageDeliveryState?
    var interrupt: Action?
}

// MARK: - Conformances

extension _ChatViewPreferences: MergeOperatable {
    public mutating func mergeInPlace(with other: Self) {
        self.itemActivities.merge(other.itemActivities, uniquingKeysWith: { lhs, rhs in rhs })
        self.messageDeliveryState ??= other.messageDeliveryState
        self.interrupt ??= other.interrupt
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
