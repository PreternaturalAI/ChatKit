//
//  Untitled.swift
//  ChatKit
//
//  Created by Jared Davidson on 1/17/25.
//

import SwiftUIZ
import NaturalLanguage

public struct TranslationHandler {
    let view: (String) -> AnyView
    public let action: (String) -> Void
    let shouldAutoTranslate: () -> Bool  // Renamed here
    
    public init<V: View>(
        @ViewBuilder view: @escaping (String) -> V,
        action: @escaping (String) -> Void,
        shouldAutoTranslate: @escaping () -> Bool  // Renamed here
    ) {
        self.view = { AnyView(view($0)) }
        self.action = action
        self.shouldAutoTranslate = shouldAutoTranslate
    }
}

extension ChatItemCellStyle where Self == TranslationStyle {
    public static var translation: TranslationStyle {
        TranslationStyle()
    }
}

// MARK: - Language Detection Helper
public func isTextInDifferentLocale(_ text: String, locale: Locale = .current) -> Bool {
    let languageDetector = NLLanguageRecognizer()
    languageDetector.processString(text)
    
    guard let detectedLanguage = languageDetector.dominantLanguage?.rawValue else {
        return false
    }
    
    return locale.language.languageCode?.identifier != detectedLanguage
}

// MARK: - Translation Style
public struct TranslationStyle: ChatItemCellStyle {
    @Environment(\.translationLocale) private var targetLocale
    @Environment(\.translationHandler) private var translationHandler
    @State private var shouldShowTranslation: Bool = false
    
    public init() {}
    
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
               let handler = translationHandler,
               isTextInDifferentLocale(content, locale: targetLocale) {
                HStack {
                    if try! configuration.item.isSender {
                        Spacer()
                    }
                    
                    Button(action: {
                        shouldShowTranslation.toggle()
                        if !shouldShowTranslation {
                            return
                        }
                        handler.action(content)
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
                .frame(height: 20)
            } else {
                EmptyView()
                    .frame(height: 20)
            }
        }
        .background(Color.almostClear)
        .onAppear {
            if let content = configuration.item.body,
               let handler = translationHandler,
               handler.shouldAutoTranslate() {  // Changed here
                shouldShowTranslation = true
                handler.action(content)
            }
        }
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

// MARK: - View Extensions
public extension View {
    func shouldAutoTranslate(  // Renamed here
        _ shouldAutoTranslate: @escaping () -> Bool
    ) -> some View {
        modifier(TranslationConditionModifier(shouldAutoTranslate: shouldAutoTranslate))
    }
    
    func onTranslate<V: View>(
        action: @escaping (String) -> Void,
        @ViewBuilder label: @escaping (String) -> V
    ) -> some View {
        modifier(TranslationActionModifier(action: action, label: label))
    }
    
    func translationLocale(_ locale: Locale) -> some View {
        environment(\.translationLocale, locale)
    }
}

// MARK: - Modifiers
private struct TranslationConditionModifier: ViewModifier {
    let shouldAutoTranslate: () -> Bool  // Renamed here
    
    func body(content: Content) -> some View {
        content.environment(\.translationShouldTranslate, shouldAutoTranslate)
    }
}

private struct TranslationActionModifier: ViewModifier {
    @Environment(\.translationShouldTranslate) private var shouldAutoTranslate  // Renamed here
    
    let action: (String) -> Void
    let label: (String) -> AnyView
    
    init<V: View>(
        action: @escaping (String) -> Void,
        @ViewBuilder label: @escaping (String) -> V
    ) {
        self.action = action
        self.label = { AnyView(label($0)) }
    }
    
    func body(content: Content) -> some View {
        content.environment(
            \.translationHandler,
            TranslationHandler(
                view: label,
                action: action,
                shouldAutoTranslate: shouldAutoTranslate ?? { false }  // Renamed here
            )
        )
    }
}

// MARK: - Environment Keys
public struct TranslationLocaleKey: EnvironmentKey {
    public static var defaultValue: Locale = .current
}

public struct TranslationHandlerKey: EnvironmentKey {
    public static var defaultValue: TranslationHandler? = nil
}

private struct TranslationShouldTranslateKey: EnvironmentKey {
    static var defaultValue: (() -> Bool)? = nil
}

public extension EnvironmentValues {
    var translationLocale: Locale {
        get { self[TranslationLocaleKey.self] }
        set { self[TranslationLocaleKey.self] = newValue }
    }
    
    var translationHandler: TranslationHandler? {
        get { self[TranslationHandlerKey.self] }
        set { self[TranslationHandlerKey.self] = newValue }
    }
    
    var translationShouldTranslate: (() -> Bool)? {
        get { self[TranslationShouldTranslateKey.self] }
        set { self[TranslationShouldTranslateKey.self] = newValue }
    }
}
