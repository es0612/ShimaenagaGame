import Testing
import Foundation
@testable import ShimaenagaGameCore

@Suite("GameLogic Tests")
struct GameLogicTests {
    
    @Test("GameLogic should initialize successfully")
    func initialization() async throws {
        let gameLogic = GameLogic()
        // GameLogic should be a simple struct that can be initialized
        // Just verify it exists and has the expected methods
        let pet = ShimaenagaPet()
        let _ = gameLogic.feedPet(pet)
    }
    
    @Test("feedPet should increase hunger level")
    func feedPetIncreasesHunger() async throws {
        let gameLogic = GameLogic()
        var pet = ShimaenagaPet(name: "テストペット")
        pet.hungerLevel = 30
        
        let updatedPet = gameLogic.feedPet(pet)
        
        #expect(updatedPet.hungerLevel > pet.hungerLevel)
        #expect(updatedPet.hungerLevel <= 100) // Should not exceed maximum
    }
    
    @Test("feedPet should update lastFeedTime")
    func feedPetUpdatesLastFeedTime() async throws {
        let gameLogic = GameLogic()
        let pet = ShimaenagaPet(name: "テストペット")
        let originalFeedTime = pet.lastFeedTime
        
        // Wait a small amount to ensure time difference
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        let updatedPet = gameLogic.feedPet(pet)
        
        #expect(updatedPet.lastFeedTime > originalFeedTime)
    }
    
    @Test("feedPet should not exceed maximum hunger level")
    func feedPetDoesNotExceedMaximum() async throws {
        let gameLogic = GameLogic()
        var pet = ShimaenagaPet(name: "テストペット")
        pet.hungerLevel = 95
        
        let updatedPet = gameLogic.feedPet(pet)
        
        #expect(updatedPet.hungerLevel == 100)
    }
    
    @Test("playWithPet should increase happiness level")
    func playWithPetIncreasesHappiness() async throws {
        let gameLogic = GameLogic()
        var pet = ShimaenagaPet(name: "テストペット")
        pet.happinessLevel = 30
        
        let updatedPet = gameLogic.playWithPet(pet)
        
        #expect(updatedPet.happinessLevel > pet.happinessLevel)
        #expect(updatedPet.happinessLevel <= 100) // Should not exceed maximum
    }
    
    @Test("playWithPet should update lastPlayTime")
    func playWithPetUpdatesLastPlayTime() async throws {
        let gameLogic = GameLogic()
        let pet = ShimaenagaPet(name: "テストペット")
        let originalPlayTime = pet.lastPlayTime
        
        // Wait a small amount to ensure time difference
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        let updatedPet = gameLogic.playWithPet(pet)
        
        #expect(updatedPet.lastPlayTime > originalPlayTime)
    }
    
    @Test("playWithPet should not exceed maximum happiness level")
    func playWithPetDoesNotExceedMaximum() async throws {
        let gameLogic = GameLogic()
        var pet = ShimaenagaPet(name: "テストペット")
        pet.happinessLevel = 95
        
        let updatedPet = gameLogic.playWithPet(pet)
        
        #expect(updatedPet.happinessLevel == 100)
    }
    
    @Test("updatePetStatus should decrease hunger over time")
    func updatePetStatusDecreasesHungerOverTime() async throws {
        let gameLogic = GameLogic()
        var pet = ShimaenagaPet(name: "テストペット")
        pet.hungerLevel = 80
        pet.lastFeedTime = Date().addingTimeInterval(-3600) // 1 hour ago
        
        let updatedPet = gameLogic.updatePetStatus(pet)
        
        #expect(updatedPet.hungerLevel < pet.hungerLevel)
        #expect(updatedPet.hungerLevel >= 0) // Should not go below minimum
    }
    
    @Test("updatePetStatus should decrease happiness over time")
    func updatePetStatusDecreasesHappinessOverTime() async throws {
        let gameLogic = GameLogic()
        var pet = ShimaenagaPet(name: "テストペット")
        pet.happinessLevel = 80
        pet.lastPlayTime = Date().addingTimeInterval(-3600) // 1 hour ago
        
        let updatedPet = gameLogic.updatePetStatus(pet)
        
        #expect(updatedPet.happinessLevel < pet.happinessLevel)
        #expect(updatedPet.happinessLevel >= 0) // Should not go below minimum
    }
    
    @Test("updatePetStatus should not decrease status if recently fed/played")
    func updatePetStatusNoDecayIfRecent() async throws {
        let gameLogic = GameLogic()
        var pet = ShimaenagaPet(name: "テストペット")
        pet.hungerLevel = 80
        pet.happinessLevel = 80
        pet.lastFeedTime = Date() // Just now
        pet.lastPlayTime = Date() // Just now
        
        let updatedPet = gameLogic.updatePetStatus(pet)
        
        // Status should remain the same or decrease very little
        #expect(updatedPet.hungerLevel >= pet.hungerLevel - 5)
        #expect(updatedPet.happinessLevel >= pet.happinessLevel - 5)
    }
    
    @Test("updatePetStatus should affect health based on hunger and happiness")
    func updatePetStatusAffectsHealth() async throws {
        let gameLogic = GameLogic()
        var pet = ShimaenagaPet(name: "テストペット")
        pet.hungerLevel = 10 // Very hungry
        pet.happinessLevel = 10 // Very unhappy
        pet.healthLevel = 100
        
        let updatedPet = gameLogic.updatePetStatus(pet)
        
        // Health should decrease when pet is hungry and unhappy
        #expect(updatedPet.healthLevel < pet.healthLevel)
        #expect(updatedPet.healthLevel >= 0) // Should not go below minimum
    }
    
    @Test("updatePetStatus should maintain health when pet is well cared for")
    func updatePetStatusMaintainsHealthWhenWellCaredFor() async throws {
        let gameLogic = GameLogic()
        var pet = ShimaenagaPet(name: "テストペット")
        pet.hungerLevel = 90 // Well fed
        pet.happinessLevel = 90 // Very happy
        pet.healthLevel = 100
        
        let updatedPet = gameLogic.updatePetStatus(pet)
        
        // Health should remain high when pet is well cared for
        #expect(updatedPet.healthLevel >= 95)
    }
    
    @Test("updatePetStatus should not go below minimum values")
    func updatePetStatusRespectsMinimumsValues() async throws {
        let gameLogic = GameLogic()
        var pet = ShimaenagaPet(name: "テストペット")
        pet.hungerLevel = 0
        pet.happinessLevel = 0
        pet.healthLevel = 0
        pet.lastFeedTime = Date().addingTimeInterval(-86400) // 24 hours ago
        pet.lastPlayTime = Date().addingTimeInterval(-86400) // 24 hours ago
        
        let updatedPet = gameLogic.updatePetStatus(pet)
        
        #expect(updatedPet.hungerLevel >= 0)
        #expect(updatedPet.happinessLevel >= 0)
        #expect(updatedPet.healthLevel >= 0)
    }
    
    @Test("GameLogic should be Sendable")
    func gameLogicSendable() async throws {
        let gameLogic = GameLogic()
        
        // Test that we can send the gameLogic across actor boundaries
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                let _ = gameLogic // Should compile without warnings
            }
        }
    }
}