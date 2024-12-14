> [!IMPORTANT]
> This package is presently in its alpha stage of development

[![Build all  platforms](https://github.com/PreternaturalAI/ChatKit/actions/workflows/swift.yml/badge.svg)](https://github.com/PreternaturalAI/ChatKit/actions/workflows/swift.yml)

# ChatKit

A protocol-oriented, batteries-included framework for building chat interfaces in Swift.

<img width="748" alt="export47277785-6DB0-40DA-A01A-E1E94689B074" src="https://github.com/user-attachments/assets/c55250c1-f697-4527-818c-58847491156f" />

# Installation

## Swift Package Manager

1. Open your Swift project in Xcode.
2. Go to `File` -> `Add Package Dependency`.
3. In the search bar, enter the URL: [https://github.com/PreternaturalAI/ChatKit](https://github.com/PreternaturalAI/ChatKit).
4. Choose the version you'd like to install.
5. Click `Add Package`.

# Usage

## Import the framework

```diff
+ import ChatKit
```

## Create a local `Message` object 
For example: 
```swift
public struct Message: Codable, Hashable, Identifiable, Sendable {
    public enum Role: Codable, Hashable, Sendable {
        case user
        case assistant
    }
    
    public var id = UUID()
    public var creationDate: Date = Date()
    public var text: String
    public var role: Role = .user
}
```
## Add the `ChatKit.ChatView` into your view
```swift
import SwiftUI
import ChatKit

struct ContentView: View {

    // tracks user message input
    @State private var inputFieldText: String = ""
    
    let messages = [
        Message(text: "User Message", role: .user),
        Message(text: "Assistant Message", role: .assistant),
    ]
    
    var body: some View {
        ChatKit.ChatView {
            ChatMessageList(
                messages
            ) { (message: Message) in
                ChatItemCell(item: AnyChatMessage(message.text))
                     // logic for when to show the grey reply bubble
                    .roleInvert(message.role == .assistant)
                    .onDelete {
                        // handle message deletion
                    }
                    .onEdit { message in
                        // handle message editing
                    }
                    .onResend {
                        // handle resending message
                    }
                    .cocoaListItem(id: message.id)
                    .chatItemDecoration(placement: .besideItem) {
                        // message decoration for delete / resend / edit actions
                        Menu {
                            // automatically includes the configured actions above
                            // (e.g. Delete / Edit / Resend)
                            ChatItemActions()
                        } label: {
                            Image(systemName: .squareAndPencil)
                                .foregroundColor(.secondary)
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .menuStyle(.button)
                        .buttonStyle(.plain)
                    }
            }
            
            if messages.isEmpty {
                ContentUnavailableView("No Messages", systemImage: "message.fill")
            }
        } input: {
            // message input
            ChatInputBar(
                text: $inputFieldText
            ) { message in
                // handle message sending
            }
        }
    }
}
```

