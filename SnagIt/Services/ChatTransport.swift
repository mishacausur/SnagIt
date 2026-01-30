//
//  ChatTransport.swift
//  SnagIt
//
//  Created by Misha Causur on 30.01.2026.
//

import Foundation

protocol ChatTransport: Sendable {
    func fetchChats() async throws -> [Chat]
    func fetchMessages(chatId: UUID, before: Date?, limit: Int) async throws -> [Message]
    func sendMessage(chatId: UUID, text: String) async throws -> Message
    func incomingMessages(chatId: UUID) -> AsyncStream<Message>
}
