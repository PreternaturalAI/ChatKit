//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

public enum _ChatItemActivity: Hashable {
    case sending
    case inProgress
    case failed(AnyError)
}

public struct ChatItemActivity: Identifiable, View {
    public let id: AnyChatItemIdentifier
    public let value: _ChatItemActivity
    
    public init(id: some Hashable, _ value: _ChatItemActivity) {
        self.id = AnyChatItemIdentifier(base: id)
        self.value = value
    }
    
    public var body: some View {
        PreferenceValue(
            key: _ChatViewPreferences._PreferenceKey.self,
            value: _ChatViewPreferences(itemActivities: [id: value])
        )
    }
}

