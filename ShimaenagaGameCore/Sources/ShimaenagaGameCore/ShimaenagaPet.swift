//
//  ShimaenagaPet.swift
//  ShimaenagaGameCore
//
//  Created on 2025/08/21
//

import Foundation

/// Represents a Shimaenaga pet with all its properties and status levels
public struct ShimaenagaPet: Codable, Sendable {
    /// Unique identifier for the pet
    public var id: UUID
    
    /// Name of the pet
    public var name: String
    
    /// Current growth stage of the pet
    public var growthStage: GrowthStage
    
    /// Hunger level (0-100, where 100 is fully fed)
    public var hungerLevel: Int
    
    /// Happiness level (0-100, where 100 is maximum happiness)
    public var happinessLevel: Int
    
    /// Health level (0-100, where 100 is perfect health)
    public var healthLevel: Int
    
    /// Last time the pet was fed
    public var lastFeedTime: Date
    
    /// Last time the pet was played with
    public var lastPlayTime: Date
    
    /// Birth date of the pet
    public var birthDate: Date
    
    /// Whether the pet has hatched from egg
    public var isHatched: Bool
    
    /// Initialize a new Shimaenaga pet with default values
    /// - Parameter name: Name for the pet (defaults to "シマエナガ")
    public init(name: String = "シマエナガ") {
        self.id = UUID()
        self.name = name
        self.growthStage = .egg
        self.hungerLevel = 50
        self.happinessLevel = 50
        self.healthLevel = 100
        self.lastFeedTime = Date()
        self.lastPlayTime = Date()
        self.birthDate = Date()
        self.isHatched = false
    }
}