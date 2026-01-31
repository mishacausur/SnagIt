//
//  ChatViewModel.swift
//  SnagIt
//
//  Created by Misha Causur on 31.01.2026.
//

import Foundation

@MainActor
final class ChatViewModel {

    private let store: ChatStore
    private let chatId: UUID

    private(set) var messages: [Message] = [] {
        didSet { onChange?() }
    }

    var onChange: (() -> Void)?
    private var incomingTask: Task<Void, Never>?

    init(chatId: UUID, store: ChatStore = ChatStore()) {
        self.chatId = chatId
        self.store = store
    }

    func start() {
        incomingTask?.cancel()
        incomingTask = Task { [store, chatId] in
            for await msg in store.incoming(chatId: chatId) {
                let updated = await store.applyIncoming(msg)
                self.messages = updated
            }
        }
    }

    func stop() {
        incomingTask?.cancel()
        incomingTask = nil
    }

    func loadInitial() async {
        do {
            messages = try await store.loadInitialMessages(chatId: chatId)
        } catch {
            // TODO: - error catcher
        }
    }

    func loadOlder() async {
        do {
            messages = try await store.loadOlder(chatId: chatId)
        } catch {
            // TODO: - error catcher
        }
    }

    func send(text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        do {
            messages = try await store.send(chatId: chatId, text: trimmed)
        } catch {
            // TODO: - error catcher
        }
    }
}
