//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Sideproject

@Singleton
final class DataStore: ObservableObject {
    @FileStorage(
        .appDocuments,
        path: "ChatKitExample/chats.json",
        coder: .json,
        options: .init(readErrorRecoveryStrategy: .discardAndReset)
    )
    var chats: IdentifierIndexingArrayOf<Sideproject.ChatFile> = []
}

public struct ContentView: View {
    @StateObject var dataStore: DataStore = .shared
    
    @UserStorage("navigationSelection", deferUpdates: true)
    var selection: Sideproject.ChatFile.ID?
    
    @State var llm: (any LLMRequestHandling)? = Sideproject.shared
    
    public var body: some View {
        NavigationSplitView {
            VStack {
                List(selection: $selection) {
                    Section {
                        NavigationLink("Accounts") {
                            SideprojectAccountsView()
                        }
                    }
                    
                    Section("Chats") {
                        ForEach(dataStore.chats) { (chat: Sideproject.ChatFile) in
                            NavigationLink(value: chat.id) {
                                Group {
                                    Text(chat.metadata.displayName)
                                }
                                .frame(width: .greedy, alignment: .leading)
                                .id(chat.id)
                            }
                        }
                    }
                }
                
                PathControl(url: try! dataStore.$chats.url)
                    .padding()
            }
            .navigationSplitViewColumnWidth(256)
        } detail: {
            Group {
                if
                    let llm = llm,
                    let selection = selection,
                    let chat: Sideproject.ChatFile = dataStore.chats[id: selection]
                {
                    Sideproject.ChatView(
                        messages: chat.messages,
                        llm: llm
                    )
                }
            }
            .id(selection)
        }
        .toolbar {
            Button("New Chat", systemImage: .plus) {
                dataStore.chats.append(.init())
            }
        }
    }
}
