//
//  ChatModel.swift
//  SnagIt
//
//  Created by Misha Causur on 30.01.2026.
//

import Foundation

struct Chat: Identifiable, Equatable, Sendable {
    let id: UUID
    var title: String
    var lastMessagePreview: String?
    var lastActivity: Date
}
