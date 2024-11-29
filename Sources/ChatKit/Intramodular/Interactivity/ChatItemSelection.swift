//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX

public protocol _ChatItemSelectionType: DynamicProperty {
    var isEmpty: Bool { get }
}

public struct ChatItemSelection: _ChatItemSelectionType, View {
    public var binding: Binding<AnyChatItemIdentifier?>
    
    public var isEmpty: Bool {
        binding.wrappedValue == nil
    }
    
    public init<ID: Hashable>(_ item: Binding<ID?>) {
        self.binding = Binding(
            get: { item.wrappedValue.map({ AnyChatItemIdentifier(base: $0) }) },
            set: { item.wrappedValue = $0.map({ $0.base.base as! ID }) }
        )
    }
    
    public var body: some View {
        ZeroSizeView()
            .trait(self)
    }
}

public struct ChatItemMultipleSelection: _ChatItemSelectionType, View {
    public var binding: Binding<Set<AnyChatItemIdentifier>>
    
    public var isEmpty: Bool {
        binding.wrappedValue.isEmpty
    }
    
    public init<ID: Hashable>(_ binding: Binding<Set<ID>>) {
        self.binding = Binding(
            get: {
                Set(
                    binding.wrappedValue.map {
                        AnyChatItemIdentifier(base: $0.eraseToAnyHashable())
                    }
                )
            },
            set: {
                binding.wrappedValue = Set(
                    $0.map {
                        $0.base.base as! ID
                    }
                )
            }
        )
    }
    
    public var body: some View {
        ZeroSizeView()
            .trait(self)
    }
}
