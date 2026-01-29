//
//  PriceAPIError.swift
//  SnagIt
//
//  Created by Misha Causur on 29.01.2026.
//

import Foundation

enum PriceAPIError: Error, Equatable {
    case offline
    case rateLimited
    case server(String)
    case invalidItem
}

protocol PriceAPI {
    func fetchPrice(for item: TrackedItem) async throws -> PricePoint
}
