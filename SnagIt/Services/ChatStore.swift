//
//  ChatStore.swift
//  SnagIt
//
//  Created by Misha Causur on 30.01.2026.
//


import Foundation

actor ChatStore {

    private let transport: ChatTransport
    private(set) var chats: [Chat] = []
    private var messagesByChat: [UUID: [Message]] = [:]

    init(transport: ChatTransport = MockChatTransport()) {
        self.transport = transport
    }

    func loadChats() async throws -> [Chat] {
        let fetched = try await transport.fetchChats()
        chats = fetched.sorted { $0.lastActivity > $1.lastActivity }
        return chats
    }

    func snapshotMessages(chatId: UUID) -> [Message] {
        (messagesByChat[chatId] ?? []).sorted { $0.sentAt < $1.sentAt }
    }

    func loadInitialMessages(chatId: UUID) async throws -> [Message] {
        let fetched = try await transport.fetchMessages(chatId: chatId, before: nil, limit: 30)
        messagesByChat[chatId] = fetched
        return snapshotMessages(chatId: chatId)
    }

    func loadOlder(chatId: UUID) async throws -> [Message] {
        let current = messagesByChat[chatId] ?? []
        let before = current.first?.sentAt
        let older = try await transport.fetchMessages(chatId: chatId, before: before, limit: 20)
        messagesByChat[chatId] = (older + current)
        return snapshotMessages(chatId: chatId)
    }

    func send(chatId: UUID, text: String) async throws -> [Message] {
        let sent = try await transport.sendMessage(chatId: chatId, text: text)
        var arr = messagesByChat[chatId] ?? []
        arr.append(sent)
        messagesByChat[chatId] = arr
        return snapshotMessages(chatId: chatId)
    }

    nonisolated func incoming(chatId: UUID) -> AsyncStream<Message> {
        transport.incomingMessages(chatId: chatId)
    }

    func applyIncoming(_ message: Message) -> [Message] {
        var arr = messagesByChat[message.chatId] ?? []
        arr.append(message)
        messagesByChat[message.chatId] = arr
        return snapshotMessages(chatId: message.chatId)
    }
}
