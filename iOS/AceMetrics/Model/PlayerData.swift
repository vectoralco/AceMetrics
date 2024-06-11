//
//  PlayerData.swift
//
//  Created by Vijayakumar B on 23/03/21.
//

//  AceMetrics
//
// Copyright (C) 2024 Vectoral Innovations (OPC) Pvt. Ltd
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation
import SwiftUI
import CoreData

enum PlayingHand : Int16, Codable {
    case Right=0, Left
}

extension Player {
    var playingHandValue: PlayingHand {
        get {
            return PlayingHand(rawValue: self.playingHand) ?? .Right
        }
        set {
            self.playingHand = newValue.rawValue
        }
    }
    
    func hasSessions() -> Bool {
        if sessions?.count ?? 0 > 0 {
            return true
        }
        
        return false
    }
    
    func isSessionActive() -> Bool {
        if sessionId != nil {
            if let sessionArray = self.sessions?.allObjects as? [ServiceSession] {
                for session in sessionArray {
                    if session.id == self.sessionId && session.active {
                        return true
                    }
                }
            }
        }
        
        return false
    }
}

final class PlayerData : ObservableObject {
    @Published var playerDictionary: Dictionary<String, [Player]> = [:]
    @Published var fetchInProgress = false
    private var viewContext = PersistenceController.shared.container.viewContext
    private var fetchRetryCount: Int = 0
    private weak var timer: Timer?
    private var numPlayers: Int = 0
    
    init() {
        fetch()
        
        let hasLaunched = UserDefaults.standard.bool(forKey: "hasLaunched")
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: "hasLaunched")
            if playerDictionary.isEmpty {
                self.fetchInProgress = true
                self.fetchRetryCount = 5
                timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(fetchRetry), userInfo: nil, repeats: true)
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    @objc func fetchRetry() {
        fetchRetryCount -= 1
        
        fetch()
        if !playerDictionary.isEmpty || fetchRetryCount <= 0 {
            timer?.invalidate()
            timer = nil
            fetchInProgress = false
        }
    }
    
    func fetch() {
        let fetchRequest = Player.fetchRequest()
        var players:[Player]? = nil
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"firstName", ascending:true)]
        
        do {
            players = try viewContext.fetch(fetchRequest)
            numPlayers = players?.count ?? 0
        } catch {
        }
        
        playerDictionary = {
            return Dictionary(grouping: players ?? [], by: {
                let name:String = $0.firstName ?? ""
                if !name.isEmpty {
                    let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                    let firstChar = String(normalizedName.first!).uppercased()
                    return firstChar
                }
                else {
                    return ""
                }
            })
        }()
    }
    
    var playerCount: Int {
        return numPlayers
    }
    
    func newPlayer() -> Player {
        let player = Player(context: viewContext)
        player.id = UUID()
        player.playingHandValue = .Right
        return player
    }
    
    func getPlayer(playerId: UUID?) -> Player? {
        var player: Player? = nil
        
        if let id = playerId {
            viewContext.performAndWait {
                let fetchRequest = Player.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                fetchRequest.fetchLimit = 1
                player = (try? fetchRequest.execute())?.first
            }
        } else {
            player = getFirstPlayer()
        }
        
        return player
    }
    
    func getFirstPlayer() -> Player? {
        var player: Player? = nil
        
        if !playerDictionary.isEmpty {
            for (_, players) in playerDictionary {
                player = players.first
            }
        }
        
        return player
    }
    
    func findPlayer(firstName: String, lastName: String) -> Bool {
        let normalizedName = firstName.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let firstChar = String(normalizedName.first!).uppercased()
        
        for (index, players) in playerDictionary {
            if firstChar == index {
                for player in players {
                    if firstName.caseInsensitiveCompare(player.firstName ?? "") == .orderedSame && lastName.caseInsensitiveCompare(player.lastName ?? "") == .orderedSame {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func removePlayer(playerId : UUID?) -> Error? {
        if let player = getPlayer(playerId: playerId) {
            viewContext.delete(player)
            return save()
        }
        
        return nil
    }
    
    func save() -> Error? {
        do {
            try viewContext.save()
        } catch {
            return error
        }
        
        fetch()
        
        return nil
    }
}
