import Testing
import Foundation
@testable import ShimaenagaGameCore

@Suite("ShimaenagaPet Model Tests")
struct ShimaenagaPetTests {
    
    @Test("ShimaenagaPet should initialize with default values")
    func initializeWithDefaults() async throws {
        let pet = ShimaenagaPet()
        
        #expect(pet.name == "シマエナガ")
        #expect(pet.growthStage == .egg)
        #expect(pet.hungerLevel == 50)
        #expect(pet.happinessLevel == 50)
        #expect(pet.healthLevel == 100)
        #expect(pet.isHatched == false)
        #expect(pet.id != UUID())  // Should have a unique ID
    }
    
    @Test("ShimaenagaPet should initialize with custom name")
    func initializeWithCustomName() async throws {
        let customName = "マイシマエナガ"
        let pet = ShimaenagaPet(name: customName)
        
        #expect(pet.name == customName)
        #expect(pet.growthStage == .egg)
    }
    
    @Test("ShimaenagaPet should be Codable")
    func codableConformance() async throws {
        let originalPet = ShimaenagaPet(name: "テストペット")
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalPet)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedPet = try decoder.decode(ShimaenagaPet.self, from: data)
        
        #expect(decodedPet.id == originalPet.id)
        #expect(decodedPet.name == originalPet.name)
        #expect(decodedPet.growthStage == originalPet.growthStage)
        #expect(decodedPet.hungerLevel == originalPet.hungerLevel)
        #expect(decodedPet.happinessLevel == originalPet.happinessLevel)
        #expect(decodedPet.healthLevel == originalPet.healthLevel)
    }
    
    @Test("ShimaenagaPet should be Sendable")
    func sendableConformance() async throws {
        let pet = ShimaenagaPet()
        
        // Test that we can send the pet across actor boundaries
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                let _ = pet // Should compile without warnings
            }
        }
    }
    
    @Test("ShimaenagaPet status levels should be within valid range")
    func statusLevelsValidRange() async throws {
        let pet = ShimaenagaPet()
        
        #expect(pet.hungerLevel >= 0 && pet.hungerLevel <= 100)
        #expect(pet.happinessLevel >= 0 && pet.happinessLevel <= 100)
        #expect(pet.healthLevel >= 0 && pet.healthLevel <= 100)
    }
    
    @Test("ShimaenagaPet should track time-based properties")
    func timeBasedProperties() async throws {
        let pet = ShimaenagaPet()
        let now = Date()
        
        // Allow for small time differences during test execution
        let timeDifference = abs(pet.lastFeedTime.timeIntervalSince(now))
        #expect(timeDifference < 1.0) // Less than 1 second difference
        
        let birthTimeDifference = abs(pet.birthDate.timeIntervalSince(now))
        #expect(birthTimeDifference < 1.0)
        
        let playTimeDifference = abs(pet.lastPlayTime.timeIntervalSince(now))
        #expect(playTimeDifference < 1.0)
    }
}

@Suite("GrowthStage Enum Tests")
struct GrowthStageTests {
    
    @Test("GrowthStage should have all expected cases")
    func allCases() async throws {
        let allStages = GrowthStage.allCases
        
        #expect(allStages.count == 4)
        #expect(allStages.contains(.egg))
        #expect(allStages.contains(.baby))
        #expect(allStages.contains(.child))
        #expect(allStages.contains(.adult))
    }
    
    @Test("GrowthStage should be Codable")
    func codableConformance() async throws {
        for stage in GrowthStage.allCases {
            let encoder = JSONEncoder()
            let data = try encoder.encode(stage)
            
            let decoder = JSONDecoder()
            let decodedStage = try decoder.decode(GrowthStage.self, from: data)
            
            #expect(decodedStage == stage)
        }
    }
    
    @Test("GrowthStage raw values should be correct")
    func rawValues() async throws {
        #expect(GrowthStage.egg.rawValue == "egg")
        #expect(GrowthStage.baby.rawValue == "baby")
        #expect(GrowthStage.child.rawValue == "child")
        #expect(GrowthStage.adult.rawValue == "adult")
    }
}