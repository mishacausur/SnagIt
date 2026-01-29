//
//  PricePoint.swift
//  SnagIt
//
//  Created by Misha Causur on 29.01.2026.
//

import Foundation

struct PricePoint: Codable, Equatable {
    var value: Decimal
    var currency: Currency
    var at: Date
}
