//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX

public struct _ChatMessageStack<Content: View>: View {
    private let content: Content
    
    @State private var id = UUID()
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        _IntrinsicGeometryValueReader(\.size.width) { width in
            Group {
                if let width = width, width.isNormal {
                    _VariadicViewAdapter(content) { subviews in
                        LazyVStack(spacing: 0) {
                            _ForEachSubview(subviews, id: \.chatMessageID) { (index, subview) in
                                let id = subview[trait: \.chatMessageID]
                                let role = subview[trait: \.chatMessageRole] ?? .sender
                                
                                subview
                                    .contentShape(Rectangle())
                                    .frame(maxWidth: min(width * 0.7, 800), alignment: role == .sender ? .trailing : .leading)
                                    .frame(width: .greedy, alignment: role == .sender ? .trailing : .leading)
                                    ._opaque_id(id ?? AnyHashable(index))
                            }
                        }
                        .onChange(of: subviews.isEmpty) { _ in
                            self.id = UUID()
                        }
                    }
                } else {
                    XSpacer()
                }
            }
            .frame(minWidth: 128, maxWidth: .greatestFiniteMagnitude)
        }
        .id(id)
    }
}

extension View {
    public func chatMessage<T: Hashable>(id: T, role: ChatMessageRole) -> some View {
        _trait(\.chatMessageID, id)._trait(\.chatMessageRole, role)
    }
}

public enum ChatMessageRole {
    case sender
    case recipient
    
    var isIncoming: Bool {
        self == .recipient
    }
}

extension _ViewTraitKeys {
    struct _ChatMessageIDKey: _ViewTraitKey {
        typealias Value = AnyHashable?
        
        static var defaultValue: AnyHashable? = nil
    }
    
    struct _ChatMessageRoleTraitKey: _ViewTraitKey {
        typealias Value = ChatMessageRole?
        
        static var defaultValue: ChatMessageRole? = nil
    }
    
    var chatMessageID: _ChatMessageIDKey.Type {
        _ChatMessageIDKey.self
    }
    
    var chatMessageRole: _ChatMessageRoleTraitKey.Type {
        _ChatMessageRoleTraitKey.self
    }
}
