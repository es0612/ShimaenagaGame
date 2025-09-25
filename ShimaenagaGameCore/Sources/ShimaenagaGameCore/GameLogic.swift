//
//  GameLogic.swift
//  ShimaenagaGameCore
//
//  Core game logic for pet care actions and status updates
//

import Foundation

/// Core game logic for managing pet interactions and status updates
public struct GameLogic: Sendable {
    
    /// Initialize a new GameLogic instance
    public init() {}
    
    /// Feed the pet, increasing hunger level and updating feed time
    /// - Parameter pet: The pet to feed
    /// - Returns: Updated pet with increased hunger level
    public func feedPet(_ pet: ShimaenagaPet) -> ShimaenagaPet {
        var updatedPet = pet
        
        // Increase hunger level by 20 points, capped at 100
        updatedPet.hungerLevel = min(100, pet.hungerLevel + 20)
        
        // Update last feed time
        updatedPet.lastFeedTime = Date()
        
        return updatedPet
    }
    
    /// Play with the pet, increasing happiness level and updating play time
    /// - Parameter pet: The pet to play with
    /// - Returns: Updated pet with increased happiness level
    public func playWithPet(_ pet: ShimaenagaPet) -> ShimaenagaPet {
        var updatedPet = pet
        
        // Increase happiness level by 15 points, capped at 100
        updatedPet.happinessLevel = min(100, pet.happinessLevel + 15)
        
        // Update last play time
        updatedPet.lastPlayTime = Date()
        
        return updatedPet
    }
    
    /// Update pet status based on time decay and current conditions
    /// - Parameter pet: The pet to update
    /// - Returns: Updated pet with time-based status changes
    public func updatePetStatus(_ pet: ShimaenagaPet) -> ShimaenagaPet {
        var updatedPet = pet
        let now = Date()
        
        // Calculate time since last feed (in hours)
        let hoursSinceLastFeed = now.timeIntervalSince(pet.lastFeedTime) / 3600
        
        // Calculate time since last play (in hours)
        let hoursSinceLastPlay = now.timeIntervalSince(pet.lastPlayTime) / 3600
        
        // Hunger decay: 5 points per hour, minimum 0
        let hungerDecay = Int(hoursSinceLastFeed * 5)
        updatedPet.hungerLevel = max(0, pet.hungerLevel - hungerDecay)
        
        // Happiness decay: 3 points per hour, minimum 0
        let happinessDecay = Int(hoursSinceLastPlay * 3)
        updatedPet.happinessLevel = max(0, pet.happinessLevel - happinessDecay)
        
        // Health calculation based on hunger and happiness
        updatedPet.healthLevel = calculateHealth(
            hungerLevel: updatedPet.hungerLevel,
            happinessLevel: updatedPet.happinessLevel,
            currentHealth: pet.healthLevel
        )
        
        return updatedPet
    }
    
    /// Calculate health level based on hunger, happiness, and current health
    /// - Parameters:
    ///   - hungerLevel: Current hunger level (0-100)
    ///   - happinessLevel: Current happiness level (0-100)
    ///   - currentHealth: Current health level (0-100)
    /// - Returns: Updated health level (0-100)
    private func calculateHealth(hungerLevel: Int, happinessLevel: Int, currentHealth: Int) -> Int {
        // If pet is well fed (>70) and happy (>70), maintain or slightly improve health
        if hungerLevel > 70 && happinessLevel > 70 {
            return min(100, currentHealth + 1)
        }
        
        // If pet is moderately cared for, maintain health
        if hungerLevel > 40 && happinessLevel > 40 {
            return currentHealth
        }
        
        // If pet is poorly cared for, decrease health
        let healthDecay = calculateHealthDecay(hungerLevel: hungerLevel, happinessLevel: happinessLevel)
        return max(0, currentHealth - healthDecay)
    }
    
    /// Calculate health decay based on hunger and happiness levels
    /// - Parameters:
    ///   - hungerLevel: Current hunger level (0-100)
    ///   - happinessLevel: Current happiness level (0-100)
    /// - Returns: Health decay amount
    private func calculateHealthDecay(hungerLevel: Int, happinessLevel: Int) -> Int {
        var decay = 0
        
        // Health decreases more when pet is very hungry or very unhappy
        if hungerLevel < 20 {
            decay += 3
        } else if hungerLevel < 40 {
            decay += 1
        }
        
        if happinessLevel < 20 {
            decay += 2
        } else if happinessLevel < 40 {
            decay += 1
        }
        
        return decay
    }
    
    // MARK: - Growth System
    
    /// Check if a pet can grow to the next stage
    /// - Parameter pet: The pet to check
    /// - Returns: The next growth stage if the pet can grow, nil otherwise
    public func canPetGrow(_ pet: ShimaenagaPet) -> GrowthStage? {
        // Get the next growth stage
        guard let nextStage = GrowthRules.nextGrowthStage(from: pet.growthStage) else {
            return nil // Already at maximum growth
        }
        
        // Check time requirement
        let timeRequired = GrowthRules.timeRequiredForGrowth(from: pet.growthStage)
        let timeSinceBirth = Date().timeIntervalSince(pet.birthDate)
        
        if timeSinceBirth < timeRequired {
            return nil // Not enough time has passed
        }
        
        // Check stat requirements
        let requiredStats = GrowthRules.minimumStatsForGrowth(to: nextStage)
        
        if pet.hungerLevel < requiredStats.hunger ||
           pet.happinessLevel < requiredStats.happiness ||
           pet.healthLevel < requiredStats.health {
            return nil // Stats don't meet requirements
        }
        
        return nextStage
    }
    
    /// Grow a pet to the specified stage
    /// - Parameters:
    ///   - pet: The pet to grow
    ///   - targetStage: The target growth stage
    /// - Returns: Updated pet with new growth stage
    public func growPet(_ pet: ShimaenagaPet, to targetStage: GrowthStage) -> ShimaenagaPet {
        var updatedPet = pet
        
        // Update growth stage
        updatedPet.growthStage = targetStage
        
        // Special handling for hatching from egg
        if pet.growthStage == .egg && targetStage != .egg {
            updatedPet.isHatched = true
        }
        
        return updatedPet
    }
}