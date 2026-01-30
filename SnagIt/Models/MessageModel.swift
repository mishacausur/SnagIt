//
//  MessageModel.swift
//  SnagIt
//
//  Created by Misha Causur on 30.01.2026.
//

import Foundation

struct Message: Identifiable, Equatable, Sendable {
    let id: UUID
    let chatId: UUID
    let author: Author
    let text: String
    let sentAt: Date

    enum Author: Equatable, Sendable {
        case me
        case other(String)
    }
}
