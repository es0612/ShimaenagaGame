import Testing
import Foundation
@testable import ShimaenagaGameCore

@Suite("GrowthRules Tests")
struct GrowthRulesTests {
    
    @Test("GrowthRules should provide time requirements for each growth stage")
    func timeRequirementsForGrowthStages() async throws {
        // Test time requirements for each stage
        let eggTime = GrowthRules.timeRequiredForGrowth(from: .egg)
        let babyTime = GrowthRules.timeRequiredForGrowth(from: .baby)
        let childTime = GrowthRules.timeRequiredForGrowth(from: .child)
        let adultTime = GrowthRules.timeRequiredForGrowth(from: .adult)
        
        // Egg should require 24 hours (86400 seconds)
        #expect(eggTime == 24 * 60 * 60)
        
        // Baby should require 48 hours
        #expect(babyTime == 48 * 60 * 60)
        
        // Child should require 72 hours
        #expect(childTime == 72 * 60 * 60)
        
        // Adult should require 0 (no further growth)
        #expect(adultTime == 0)
    }
    
    @Test("GrowthRules should provide minimum stats for growth to each stage")
    func minimumStatsForGrowthStages() async throws {
        // Test minimum stats for growing to baby
        let babyStats = GrowthRules.minimumStatsForGrowth(to: .baby)
        #expect(babyStats.hunger == 60)
        #expect(babyStats.happiness == 50)
        #expect(babyStats.health == 80)
        
        // Test minimum stats for growing to child
        let childStats = GrowthRules.minimumStatsForGrowth(to: .child)
        #expect(childStats.hunger == 70)
        #expect(childStats.happiness == 60)
        #expect(childStats.health == 85)
        
        // Test minimum stats for growing to adult
        let adultStats = GrowthRules.minimumStatsForGrowth(to: .adult)
        #expect(adultStats.hunger == 80)
        #expect(adultStats.happiness == 70)
        #expect(adultStats.health == 90)
        
        // Test egg stage (should be 0 for all)
        let eggStats = GrowthRules.minimumStatsForGrowth(to: .egg)
        #expect(eggStats.hunger == 0)
        #expect(eggStats.happiness == 0)
        #expect(eggStats.health == 0)
    }
    
    @Test("canPetGrow should return nil when pet cannot grow")
    func canPetGrowReturnNilWhenCannotGrow() async throws {
        let gameLogic = GameLogic()
        
        // Test with egg that hasn't met time requirement
        var eggPet = ShimaenagaPet(name: "テストペット")
        eggPet.growthStage = .egg
        eggPet.birthDate = Date() // Just born
        eggPet.hungerLevel = 100
        eggPet.happinessLevel = 100
        eggPet.healthLevel = 100
        
        let canGrow = gameLogic.canPetGrow(eggPet)
        #expect(canGrow == nil)
    }
    
    @Test("canPetGrow should return nil when pet has insufficient stats")
    func canPetGrowReturnNilWithInsufficientStats() async throws {
        let gameLogic = GameLogic()
        
        // Test with egg that meets time but not stats
        var eggPet = ShimaenagaPet(name: "テストペット")
        eggPet.growthStage = .egg
        eggPet.birthDate = Date().addingTimeInterval(-25 * 60 * 60) // 25 hours ago
        eggPet.hungerLevel = 30 // Below required 60
        eggPet.happinessLevel = 30 // Below required 50
        eggPet.healthLevel = 50 // Below required 80
        
        let canGrow = gameLogic.canPetGrow(eggPet)
        #expect(canGrow == nil)
    }
    
    @Test("canPetGrow should return next stage when pet can grow")
    func canPetGrowReturnNextStageWhenCanGrow() async throws {
        let gameLogic = GameLogic()
        
        // Test egg that can grow to baby
        var eggPet = ShimaenagaPet(name: "テストペット")
        eggPet.growthStage = .egg
        eggPet.birthDate = Date().addingTimeInterval(-25 * 60 * 60) // 25 hours ago
        eggPet.hungerLevel = 70
        eggPet.happinessLevel = 60
        eggPet.healthLevel = 90
        
        let canGrow = gameLogic.canPetGrow(eggPet)
        #expect(canGrow == .baby)
    }
    
    @Test("canPetGrow should work for all growth stages")
    func canPetGrowWorksForAllStages() async throws {
        let gameLogic = GameLogic()
        
        // Test baby that can grow to child
        var babyPet = ShimaenagaPet(name: "テストペット")
        babyPet.growthStage = .baby
        babyPet.birthDate = Date().addingTimeInterval(-50 * 60 * 60) // 50 hours ago
        babyPet.hungerLevel = 80
        babyPet.happinessLevel = 70
        babyPet.healthLevel = 90
        
        let canGrowToChild = gameLogic.canPetGrow(babyPet)
        #expect(canGrowToChild == .child)
        
        // Test child that can grow to adult
        var childPet = ShimaenagaPet(name: "テストペット")
        childPet.growthStage = .child
        childPet.birthDate = Date().addingTimeInterval(-75 * 60 * 60) // 75 hours ago
        childPet.hungerLevel = 90
        childPet.happinessLevel = 80
        childPet.healthLevel = 95
        
        let canGrowToAdult = gameLogic.canPetGrow(childPet)
        #expect(canGrowToAdult == .adult)
        
        // Test adult (should not grow further)
        var adultPet = ShimaenagaPet(name: "テストペット")
        adultPet.growthStage = .adult
        adultPet.birthDate = Date().addingTimeInterval(-100 * 60 * 60) // 100 hours ago
        adultPet.hungerLevel = 100
        adultPet.happinessLevel = 100
        adultPet.healthLevel = 100
        
        let canGrowFromAdult = gameLogic.canPetGrow(adultPet)
        #expect(canGrowFromAdult == nil)
    }
    
    @Test("growPet should advance pet to next growth stage")
    func growPetAdvancesToNextStage() async throws {
        let gameLogic = GameLogic()
        
        // Test growing from egg to baby
        var eggPet = ShimaenagaPet(name: "テストペット")
        eggPet.growthStage = .egg
        eggPet.isHatched = false
        
        let grownPet = gameLogic.growPet(eggPet, to: .baby)
        
        #expect(grownPet.growthStage == .baby)
        #expect(grownPet.isHatched == true) // Should be hatched when growing from egg
    }
    
    @Test("growPet should maintain pet properties")
    func growPetMaintainsProperties() async throws {
        let gameLogic = GameLogic()
        
        var pet = ShimaenagaPet(name: "特別なペット")
        pet.growthStage = .baby
        pet.hungerLevel = 85
        pet.happinessLevel = 75
        pet.healthLevel = 95
        pet.lastFeedTime = Date().addingTimeInterval(-1000)
        pet.lastPlayTime = Date().addingTimeInterval(-2000)
        pet.birthDate = Date().addingTimeInterval(-50 * 60 * 60)
        
        let grownPet = gameLogic.growPet(pet, to: .child)
        
        // Growth stage should change
        #expect(grownPet.growthStage == .child)
        
        // Other properties should be maintained
        #expect(grownPet.name == "特別なペット")
        #expect(grownPet.hungerLevel == 85)
        #expect(grownPet.happinessLevel == 75)
        #expect(grownPet.healthLevel == 95)
        #expect(grownPet.lastFeedTime == pet.lastFeedTime)
        #expect(grownPet.lastPlayTime == pet.lastPlayTime)
        #expect(grownPet.birthDate == pet.birthDate)
        #expect(grownPet.id == pet.id)
    }
    
    @Test("growPet should handle hatching from egg specially")
    func growPetHandlesHatchingSpecially() async throws {
        let gameLogic = GameLogic()
        
        var eggPet = ShimaenagaPet(name: "テストペット")
        eggPet.growthStage = .egg
        eggPet.isHatched = false
        
        let hatchedPet = gameLogic.growPet(eggPet, to: .baby)
        
        #expect(hatchedPet.growthStage == .baby)
        #expect(hatchedPet.isHatched == true)
        
        // Growing from other stages should not affect hatched status
        var babyPet = ShimaenagaPet(name: "テストペット")
        babyPet.growthStage = .baby
        babyPet.isHatched = true
        
        let childPet = gameLogic.growPet(babyPet, to: .child)
        #expect(childPet.isHatched == true)
    }
    
    @Test("Growth system integration test")
    func growthSystemIntegration() async throws {
        let gameLogic = GameLogic()
        
        // Create a well-cared-for egg that meets all requirements
        var pet = ShimaenagaPet(name: "統合テストペット")
        pet.growthStage = .egg
        pet.birthDate = Date().addingTimeInterval(-25 * 60 * 60) // 25 hours old
        pet.hungerLevel = 80
        pet.happinessLevel = 70
        pet.healthLevel = 90
        pet.isHatched = false
        
        // Check if it can grow
        let nextStage = gameLogic.canPetGrow(pet)
        #expect(nextStage == .baby)
        
        // Grow the pet
        let grownPet = gameLogic.growPet(pet, to: nextStage!)
        #expect(grownPet.growthStage == .baby)
        #expect(grownPet.isHatched == true)
        
        // Verify it maintains other properties
        #expect(grownPet.name == "統合テストペット")
        #expect(grownPet.hungerLevel == 80)
        #expect(grownPet.happinessLevel == 70)
        #expect(grownPet.healthLevel == 90)
    }
}