//
//  AceMetricsUITests.swift
//  AceMetricsUITests
//
//  Created by Vijayakumar B on 01/12/24.
//

import XCTest
@testable import AceMetrics

final class AceMetricsUITests: XCTestCase {
    var context: AppContext = AppContext()
    var playerData: PlayerData = PlayerData()
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testAddPlayers() throws {
        var player = playerData.newPlayer()
        XCTAssertNotNil(player)
        player.firstName = "Roger"
        var error = playerData.save()
        XCTAssertNil(error, "save failed when adding user \(player.firstName ?? "")")
        
        player = playerData.newPlayer()
        XCTAssertNotNil(player)
        player.firstName = "Rafel"
        player.playingHandValue = PlayingHand.Left
        error = playerData.save()
        XCTAssertNil(error, "save failed when adding user \(player.firstName ?? "")")
        
        player = playerData.newPlayer()
        XCTAssertNotNil(player)
        player.firstName = "Novak"
        error = playerData.save()
        XCTAssertNil(error, "save failed when adding user \(player.lastName ?? "")")
        
        player = playerData.newPlayer()
        XCTAssertNotNil(player)
        player.firstName = "Andy"
        error = playerData.save()
        XCTAssertNil(error, "save failed when adding user \(player.lastName ?? "")")
        
        player = playerData.newPlayer()
        XCTAssertNotNil(player)
        player.firstName = "Li"
        player.lastName = "Na"
        error = playerData.save()
        XCTAssertNil(error, "save failed when adding user \(player.firstName ?? "") \(player.lastName ?? "")")
        
        let count = playerData.playerCount
        XCTAssertNotEqual(count, 0, "player list is empty")
        
        var found = playerData.findPlayer(firstName: "Roger", lastName: "")
        XCTAssert(found, "added player not found")
        
        found = playerData.findPlayer(firstName: "Andy", lastName: "")
        XCTAssert(found, "added player not found")
        
        found = playerData.findPlayer(firstName: "Li", lastName: "Na")
        XCTAssert(found, "added player not found")
        
        found = playerData.findPlayer(firstName: "Unknown", lastName: "")
        XCTAssert(!found, "played not added is found")
    }
    
    func testRemovePlayer() throws {
        playerData.fetch()
        
        let playerDictionary = playerData.playerDictionary
        for (_, players) in playerDictionary {
            for player in players {
                print("Player: \(player.firstName ?? "") \(player.lastName ?? "")")
                let error = playerData.removePlayer(playerId: player.id)
                XCTAssertNil(error, "remove player failed")
            }
        }
    }
}
