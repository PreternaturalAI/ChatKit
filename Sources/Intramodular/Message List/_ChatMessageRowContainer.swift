//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

struct _ChatMessageRowContainer<Content: View>: View {
    @Environment(\._chatViewPreferences) var _chatViewPreferences
    @Environment(\._chatItemConfiguration) var _chatItemConfiguration

    let id: AnyChatItemIdentifier
    let content: Content
    let offset: _ElementOffsetInParentCollection?
    
    var _modifiedItemConfiguration: _ChatItemConfiguration {
        withMutableScope(_chatItemConfiguration) {
            if let offset = offset, offset.isLastElement, let phase = _chatViewPreferences.activityPhaseOfLastItem, phase != .idle {
                $0.activityPhase = phase
            } else {
                $0 = nil
            }
        }
    }
    
    init(id: AnyChatItemIdentifier, offset: _ElementOffsetInParentCollection? = nil, @ViewBuilder content: () -> Content) {
        self.id = id
        self.offset = offset
        self.content = content()
    }
    
    var body: some View {
        content
            .environment(\._chatItemConfiguration, _modifiedItemConfiguration)
            .transformPreference(_ChatViewPreferences._PreferenceKey.self) { value in
                if let phase = _modifiedItemConfiguration.activityPhase {
                    value.itemActivityPhaseByItem[id] = phase
                }
            }
    }
}

