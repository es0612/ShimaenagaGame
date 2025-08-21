
//
//  CorePackageTests.swift
//  ShimaenagaPetGameTests
//
//  Created on 2025/08/21
//

import XCTest

// This import will fail because the ShimaenagaGameCore local SPM package
// has not been created or linked to the project yet.
// This failing test is the first step in our TDD cycle.
import ShimaenagaGameCore

final class CorePackageTests: XCTestCase {

    func testCorePackageCanBeImported() throws {
        // This test's purpose is to validate that the ShimaenagaGameCore module
        // is accessible from the main app's test target.
        // The test itself doesn't need to do anything complex; a successful import is the pass condition.
        XCTAssert(true, "ShimaenagaGameCore module was successfully imported.")
    }

}
