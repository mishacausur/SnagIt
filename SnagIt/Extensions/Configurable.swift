//
//  Configurable.swift
//  SnagIt
//
//  Created by Misha Causur on 01.02.2026.
//

import Foundation

protocol Configurable {}

extension NSObject: Configurable {}

extension Configurable where Self: AnyObject {
    @discardableResult
    func configure(with closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}
