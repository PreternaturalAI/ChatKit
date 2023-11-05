//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX

public protocol ChatItemSelectionProtocol {
    var isEmpty: Bool { get }
}

public struct ChatItemSelection: View {
    public var item: Binding<AnyChatItemIdentifier?>
    
    public var isEmpty: Bool {
        item.wrappedValue == nil
    }
    
    public init<ID: Hashable>(_ item: Binding<ID?>) {
        self.item = Binding(
            get: { item.wrappedValue.map({ AnyChatItemIdentifier(base: $0) }) },
            set: { item.wrappedValue = $0.map({ $0.base.base as! ID }) }
        )
    }
    
    public var body: some View {
        Text("")
    }
}

public struct ChatItemMultipleSelection: View {
    public var item: Binding<AnyChatItemIdentifier>
    
    public init<ID: Hashable>(_ item: Binding<ID>) {
        self.item = Binding(
            get: { .init(base: item.wrappedValue) },
            set: { item.wrappedValue = $0.base.base as! ID }
        )
    }
    
    public var body: some View {
        Text("")
    }
}
