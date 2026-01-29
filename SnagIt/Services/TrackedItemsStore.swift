//
//  TrackedItemsStore.swift
//  SnagIt
//
//  Created by Misha Causur on 29.01.2026.
//

import Foundation

actor TrackedItemsStore {

    private let client: PriceClient

    init(client: PriceClient = MockPriceClient()) {
        self.client = client
    }

    private(set) var items: [TrackedItem] = [
        .init(title: "On Cloud 5", source: .query("On Cloud 5")),
        .init(
            title: "Birkenstock Boston",
            source: .query("Birkenstock Boston"),
            targetPrice: 90
        ),
        .init(title: "AirPods Pro 2", source: .query("AirPods Pro 2")),
    ]

    func snapshot() -> [TrackedItem] { items }

    func add(_ item: TrackedItem) {
        items.insert(item, at: 0)
    }

    func setUpdating(_ id: UUID, _ updating: Bool) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].isUpdating = updating
    }

    func setPrice(_ id: UUID, _ point: PricePoint) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].lastPrice = point
        items[i].isUpdating = false
    }

    func setFailed(_ id: UUID) {
        guard let i = items.firstIndex(where: { $0.id == id }) else { return }
        items[i].isUpdating = false
    }

    func refresh(id: UUID) async {
        guard let item = items.first(where: { $0.id == id }) else { return }
        setUpdating(id, true)

        do {
            let point = try await client.fetchPrice(for: item.source)
            setPrice(id, point)
        } catch {
            setFailed(id)
        }
    }

    func refreshAll() async {
        let ids = items.map(\.id)

        await withTaskGroup(of: Void.self) { group in
            for id in ids {
                group.addTask { [weakSelf = self] in
                    await weakSelf.refresh(id: id)
                }
            }
        }
    }
}
