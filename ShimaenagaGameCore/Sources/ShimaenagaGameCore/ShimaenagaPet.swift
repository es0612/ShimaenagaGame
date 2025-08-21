
//
//  ShimaenagaPet.swift
//  ShimaenagaGameCore
//
//  Created on 2025/08/21
//

import Foundation

// This is a placeholder based on the design document to make the module compile.
// The full implementation will be done in a later task.
public struct ShimaenagaPet: Codable, Sendable {
    public var id: UUID
    public var name: String

    public init(name: String = "シマエナガ") {
        self.id = UUID()
        self.name = name
    }
}
