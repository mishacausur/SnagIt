//
//  TrackedItem.swift
//  SnagIt
//
//  Created by Misha Causur on 29.01.2026.
//

import Foundation

struct TrackedItem: Identifiable, Codable, Equatable, Sendable  {
    let id: UUID
    var title: String
    var source: Source
    var targetPrice: Decimal?
    var lastPrice: PricePoint?
    var isUpdating: Bool

    enum Source: Codable, Equatable {
        case url(String)
        case query(String)
    }

    init(
        id: UUID = UUID(),
        title: String,
        source: Source,
        targetPrice: Decimal? = nil,
        lastPrice: PricePoint? = nil,
        isUpdating: Bool = false
    ) {
        self.id = id
        self.title = title
        self.source = source
        self.targetPrice = targetPrice
        self.lastPrice = lastPrice
        self.isUpdating = isUpdating
    }
}
