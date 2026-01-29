//
//  MockPriceAPI.swift
//  SnagIt
//
//  Created by Misha Causur on 29.01.2026.
//

import Foundation

final class MockPriceAPI: PriceAPI {

    func fetchPrice(for item: TrackedItem) async throws -> PricePoint {

        try await Task.sleep(nanoseconds: 250_000_000)

        let r = Int.random(in: 0..<30)
        if r == 0 { throw PriceAPIError.offline }
        if r == 1 { throw PriceAPIError.rateLimited }

        let base = basePrice(for: item)
        let drift = Decimal(Int.random(in: -8...8))
        let price = max(Decimal(1), base + drift)

        return PricePoint(value: price, currency: .eur, at: Date())
    }

    private func basePrice(for item: TrackedItem) -> Decimal {
        let h = abs(item.title.hashValue % 80)
        return Decimal(60 + h)
    }
}
