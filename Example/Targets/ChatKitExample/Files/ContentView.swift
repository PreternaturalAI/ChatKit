//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Perplexity
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
    
    init() {
        chats._forEach(mutating: {
            $0.model = Perplexity.Model.llama3SonarLarge32kChat.__conversion()
        })
    }
}

public struct ContentView: View {
    @StateObject var dataStore: DataStore = .shared
    
    @UserStorage("navigationSelection", deferUpdates: true)
    var selection: Sideproject.ChatFile.ID?
    
    @State var llm: Perplexity.Client? = Perplexity.Client(apiKey: "<APIKEY>")
    
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
                    let llm: any LLMRequestHandling = llm,
                    let selection = selection,
                    let chat: Sideproject.ChatFile = dataStore.chats[id: selection]
                {
                    let chatBinding: PublishedAsyncBinding<Sideproject.ChatFile> = PublishedAsyncBinding.unwrapping(dataStore, \.chats[id: selection], defaultValue: chat)
                    
                    Sideproject.ChatView(chatBinding, llm: llm)
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
