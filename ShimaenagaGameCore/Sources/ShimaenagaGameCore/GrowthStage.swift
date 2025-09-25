//
//  GrowthStage.swift
//  ShimaenagaGameCore
//

import Foundation

/// Represents the different growth stages of a Shimaenaga pet
public enum GrowthStage: String, CaseIterable, Codable, Sendable {
    case egg = "egg"
    case baby = "baby"
    case child = "child"
    case adult = "adult"
}