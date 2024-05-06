//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

public struct ChatItemCellConfiguration {
    public let item: AnyChatMessage
    public let decorations: [ChatItemDecorationPlacement: AnyView]
    
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
