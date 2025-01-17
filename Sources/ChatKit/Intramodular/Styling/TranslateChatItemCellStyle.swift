//
//  Untitled.swift
//  ChatKit
//
//  Created by Jared Davidson on 1/17/25.
//

import SwiftUIZ
import NaturalLanguage

// MARK: - Style
extension ChatItemCellStyle where Self == TranslationStyle {
    public static var translation: TranslationStyle {
        TranslationStyle()
    }
}

// MARK: - Translation Handler
public struct TranslationHandler {
    let view: (String) -> AnyView
    let action: (String) -> Void
    
    public init<V: View>(
        @ViewBuilder view: @escaping (String) -> V,
        action: @escaping (String) -> Void
    ) {
        self.view = { AnyView(view($0)) }
        self.action = action
    }
}

// MARK: - Style Implementation
public struct TranslationStyle: ChatItemCellStyle {
    @Environment(\.translationLocale) private var targetLocale
    @Environment(\.translationHandler) private var translationHandler
    @State private var shouldShowTranslation: Bool = false
    
    public init() {}
    
    private func isTextInCurrentLocale(_ text: String) -> Bool {
        let languageDetector = NLLanguageRecognizer()
        languageDetector.processString(text)
        guard let detectedLanguage = languageDetector.dominantLanguage?.rawValue else {
            return true
        }
        return targetLocale.language.languageCode?.identifier == detectedLanguage
    }
    
    public func body(configuration: ChatItemCellConfiguration) -> some View {
        VStack(alignment: try! configuration.item.isSender ? .trailing : .leading, spacing: 0) {

            Group {
                makeContent(configuration: configuration)
                    .modifier(
                        _iMessageBubbleStyle(
                            isSender: try! configuration.item.isSender,
                            isBorderless: false,
                            error: configuration.item.activityPhase?.error
                        )
                    )
            }
            ._formStackByAdding(
                .horizontal,
                try! configuration.item.isSender ? .leading : .trailing
            ) {
                if let decoration = configuration.decorations[.besideItem] {
                    decoration
                }
            }
            
            if shouldShowTranslation,
               let content = configuration.item.body,
               let handler = translationHandler {
                handler.view(content)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            }
            
            if let content = configuration.item.body,
               !isTextInCurrentLocale(content),
               translationHandler != nil {
                HStack {
                    if try! configuration.item.isSender {
                        Spacer()
                    }
                    
                    Button(action: {
                        shouldShowTranslation.toggle()
                        if !shouldShowTranslation {
                            // Only trigger translation when showing
                            return
                        }
                        translationHandler?.action(content)
                    }) {
                        Label(shouldShowTranslation ? "Hide" : "Translate", systemImage: "globe")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    
                    if !(try! configuration.item.isSender) {
                        Spacer()
                    }
                }
            }
        }
        .background(Color.almostClear)
        .contextMenu {
            ChatItemActions()
        }
    }
    
    @ViewBuilder
    private func makeContent(
        configuration: ChatItemCellConfiguration
    ) -> some View {
        let message: AnyChatMessage = configuration.item
        
        Group {
            if message.body != nil {
                _TextChatMessageViewContent(
                    message: message,
                    isEditing: configuration.$isEditing
                )
                .modify(for: .visionOS) { content in
                    content
                        .padding(.extraSmall)
                }
                .frame(minWidth: 44, minHeight: 10)
            } else if let activityPhase = message.activityPhase {
                _AnyChatItemPlaceholderContent(phase: activityPhase)
            } else {
                _UnimplementedView()
            }
        }
        .padding(try! message.isSender ? .trailing : .leading, .extraSmall)
    }
}

// MARK: - Modifiers
public extension View {
    func translationLocale(_ locale: Locale) -> some View {
        environment(\.translationLocale, locale)
    }
    
    func onTranslate<V: View>(
        action: @escaping (String) -> Void,
        @ViewBuilder view: @escaping (String) -> V
    ) -> some View {
        environment(\.translationHandler, TranslationHandler(view: view, action: action))
    }
}

// MARK: - Environment Keys
private struct TranslationLocaleKey: EnvironmentKey {
    static var defaultValue: Locale = .current
}

private struct TranslationHandlerKey: EnvironmentKey {
    static var defaultValue: TranslationHandler? = nil
}

extension EnvironmentValues {
    var translationLocale: Locale {
        get { self[TranslationLocaleKey.self] }
        set { self[TranslationLocaleKey.self] = newValue }
    }
    
    var translationHandler: TranslationHandler? {
        get { self[TranslationHandlerKey.self] }
        set { self[TranslationHandlerKey.self] = newValue }
    }
}
