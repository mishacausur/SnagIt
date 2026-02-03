//
//  ChatService.swift
//  SnagIt
//
//  Created by Misha Causur on 03.02.2026.
//

import Foundation

actor ChatService {
    enum ChatError: Error {
        case failed
    }

    func send(_ message: String) async throws {
        let delay = UInt64(Int.random(in: 600...1400))
        try await Task.sleep(nanoseconds: delay * 1_000_000)

        if Int.random(in: 0...5) == 0 {
            throw ChatError.failed
        }
    }

    func incomingMessage() -> AsyncStream<String> {
        AsyncStream { continuation in
            let phrases: [String] = [
                "Hello, I'm SnagIt! How can I help you today?",
                "I'm just a chat assistant, I can't do anything more than that.",
                "I'm sorry, I can't assist you with that request.",
                "I'm sorry, I can't assist you with that request, but I can help you with this one instead.",
            ]

            let task = Task {
                while !Task.isCancelled {
                    let delay = UInt64(Int.random(in: 1200...3500))
                    try? await Task.sleep(nanoseconds: delay * 1_000_000)
                    continuation.yield(phrases.randomElement() ?? "ок")
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
