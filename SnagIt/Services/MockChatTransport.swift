//
//  MockChatTransport.swift
//  SnagIt
//
//  Created by Misha Causur on 30.01.2026.
//


import Foundation

struct MockChatTransport: ChatTransport {

    func fetchChats() async throws -> [Chat] {
        try await Task.sleep(nanoseconds: 250_000_000)
        return [
            Chat(id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!, title: "General", lastMessagePreview: "Yo", lastActivity: Date()),
            Chat(id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!, title: "iOS", lastMessagePreview: "actor vs @MainActor", lastActivity: Date().addingTimeInterval(-120))
        ]
    }

    func fetchMessages(chatId: UUID, before: Date?, limit: Int) async throws -> [Message] {
        try await Task.sleep(nanoseconds: 250_000_000)
        let end = before ?? Date()
        return (0..<limit).map { i in
            Message(
                id: UUID(),
                chatId: chatId,
                author: .other("Bot"),
                text: "Older message #\(i + 1)",
                sentAt: end.addingTimeInterval(TimeInterval(-(i + 1) * 60))
            )
        }.sorted { $0.sentAt < $1.sentAt }
    }

    func sendMessage(chatId: UUID, text: String) async throws -> Message {
        try await Task.sleep(nanoseconds: 180_000_000)
        return Message(id: UUID(), chatId: chatId, author: .me, text: text, sentAt: Date())
    }

    func incomingMessages(chatId: UUID) -> AsyncStream<Message> {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    try await Task.sleep(nanoseconds: UInt64(Int.random(in: 2_000_000_000...5_000_000_000)))
                    let msg = Message(
                        id: UUID(),
                        chatId: chatId,
                        author: .other("Bot"),
                        text: ["hey", "ping", "async/await ❤️", "TaskGroup?", "Sendable!"].randomElement()!,
                        sentAt: Date()
                    )
                    continuation.yield(msg)
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
