//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import SwiftUIZ

public struct ChatInputBar: View {
    @Environment(\._chatViewPreferences) private var _chatViewPreferences: _ChatViewPreferences?
    @Environment(\._chatInputBarStyle) private var chatInputBarStyle
    @Environment(\.isEnabled) private var isEnabled
    
    private let onSubmit: (String) -> Void
    
    @_ConstantOrStateOrBinding private var text: String
    
    public init(
        text: Binding<String>? = nil,
        onSubmit: @escaping (String) -> Void = { _ in }
    ) {
        if let text {
            self._text = .binding(text)
        } else {
            self._text = .state(initialValue: "")
        }
        
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        if let _chatViewPreferences {
            _WithDynamicPropertyExistential(chatInputBarStyle) {
                $0.makeBody(
                    configuration: .init(
                        textInput: _chatViewPreferences.activityPhaseOfLastItem != .sending ? textView.eraseToAnyView() : nil,
                        status: _chatViewPreferences.activityPhaseOfLastItem == nil ? nil : statusView.eraseToAnyView()
                    )
                )
                .animation(.default, value: _chatViewPreferences.activityPhaseOfLastItem)
            }
        } else {
            _UnimplementedView()
        }
    }
    
    @ViewBuilder
    public var statusView: some View {
        Group {
            if let _chatViewPreferences {
                switch _chatViewPreferences.activityPhaseOfLastItem {
                    case .sending:
                        if let stop = _chatViewPreferences.interrupt {
                            StopButton(action: stop)
                                .environment(\.isEnabled, true)
                        } else {
                            sendActivityDisclosure
                        }
                    default:
                        EmptyView()
                }
            }
        }
    }
    
    private var textView: some View {
        TextView(
            "Enter a message here",
            text: $text,
            onCommit: {
                onSubmit(text)
                
                DispatchQueue.main.async {
                    text = ""
                }
            }
        )
        .foregroundColor(.primary)
        .dismissKeyboardOnReturn(true)
        .transition(.opacity.animation(.default))
    }
    
    private var sendActivityDisclosure: some View {
        ProgressView()
            .controlSize(.regular)
            .progressViewStyle(.circular)
            .font(.body)
            .foregroundColor(.secondary)
    }
}

extension ChatInputBar {
    private struct StopButton: View {
        let action: Action
        
        var body: some View {
            Button {
                action()
            } label: {
                let sideLength: CGFloat = 44
                
                ZStack {
                    RoundedRectangle(cornerRadius: sideLength / 2)
                        .stroke(Color.primary, lineWidth: 2)
                    
                    Rectangle()
                        .fill(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .frame(width: 22, height: 22)
                }
                .squareFrame(sideLength: sideLength)
            }
            .controlSize(.regular)
            .buttonStyle(.plain)
            .transition(.identity.animation(.snappy))
        }
    }
}
