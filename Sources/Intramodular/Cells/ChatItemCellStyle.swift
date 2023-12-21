//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

public struct ChatItemCellConfiguration: _DynamicViewStyleConfiguration {
    public let item: AnyChatMessage
    
    @Binding var isEditing: Bool
}

public protocol ChatItemCellStyle: DynamicProperty {
    associatedtype Body: View
    
    @ViewBuilder
    func body(configuration: ChatItemCellConfiguration) -> Body
}

// MARK: - Supplementary

extension View {
    public func chatItemCellStyle(_ style: some ChatItemCellStyle) -> some View {
        _environment((any ChatItemCellStyle).self, style)
    }
}
