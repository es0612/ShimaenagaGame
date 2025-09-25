//
//  GrowthRules.swift
//  ShimaenagaGameCore
//
//  Business rules for pet growth conditions and requirements
//

import Foundation

/// Business rules for managing pet growth conditions and requirements
public struct GrowthRules: Sendable {
    
    /// Get the time required for a pet to grow from a specific stage
    /// - Parameter stage: The current growth stage
    /// - Returns: Time interval in seconds required to grow from this stage
    public static func timeRequiredForGrowth(from stage: GrowthStage) -> TimeInterval {
        switch stage {
        case .egg:
            return 24 * 60 * 60 // 24 hours
        case .baby:
            return 48 * 60 * 60 // 48 hours
        case .child:
            return 72 * 60 * 60 // 72 hours
        case .adult:
            return 0 // No further growth
        }
    }
    
    /// Get the minimum stats required to grow to a specific stage
    /// - Parameter stage: The target growth stage
    /// - Returns: Tuple containing minimum hunger, happiness, and health levels
    public static func minimumStatsForGrowth(to stage: GrowthStage) -> (hunger: Int, happiness: Int, health: Int) {
        switch stage {
        case .egg:
            return (0, 0, 0) // No requirements for egg stage
        case .baby:
            return (60, 50, 80) // Requirements to grow from egg to baby
        case .child:
            return (70, 60, 85) // Requirements to grow from baby to child
        case .adult:
            return (80, 70, 90) // Requirements to grow from child to adult
        }
    }
    
    /// Get the next growth stage for a given stage
    /// - Parameter currentStage: The current growth stage
    /// - Returns: The next growth stage, or nil if already at maximum
    public static func nextGrowthStage(from currentStage: GrowthStage) -> GrowthStage? {
        switch currentStage {
        case .egg:
            return .baby
        case .baby:
            return .child
        case .child:
            return .adult
        case .adult:
            return nil // No further growth
        }
    }
}