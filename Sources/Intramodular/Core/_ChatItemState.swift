//
// Copyright (c) Vatsal Manot
//

import SwiftUIZ

struct _ChatItemState {
    @Binding var isEditing: Bool
}

extension EnvironmentValues {
    @EnvironmentValue
    var _chatItemState: _ChatItemState?
}
