//
//  AceMetricsSettings.swift
//
//  Created by Vijayakumar B on 24/03/21.
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

enum ActiveView : Int, Codable {
    case Settings=0, PlayerList, ServiceSession, Statistics
}

enum CourtSide : Int, Codable {
    case Near=0, Far
    
    mutating func toggle() {
        switch self {
        case .Near:
            self = .Far
        case .Far:
            self = .Near
        }
    }
}

enum ProductId: Int {
    case Basic=0, Team, BasicToTeam
    
    var text: String {
        switch self {
        case .Basic:
            return "co.acemetrics.basic"
            
        case .Team:
            return "co.acemetrics.team"
        
        case .BasicToTeam:
            return "co.acemetrics.basic_to_team"
        }
    }
    
    var title: String {
        switch self {
        case .Basic:
            return "Basic"
            
        case .Team:
            return "Team"
        
        case .BasicToTeam:
            return "Team"
        }
    }
    
    var description: String {
        switch self {
        case .Basic:
            return "Show all session statistics"
            
        case .Team:
            return "Show all session stats + add player profiles"
        
        case .BasicToTeam:
            return "Add player profiles"
        }
    }
}

final class AppSettings {
    let version : String = "1.2.1.1"
    let productIds = [
        ProductId.Basic.text,
        ProductId.Team.text,
        ProductId.BasicToTeam.text
    ]

    var playerId : UUID? {
        didSet {
            UserDefaults.standard.set(playerId?.uuidString, forKey: "playerId")
        }
    }
    var activeView : ActiveView {
        didSet {
            UserDefaults.standard.set(activeView.rawValue, forKey:"activeView")
        }
    }
    var courtSide: CourtSide {
        didSet {
            UserDefaults.standard.set(courtSide.rawValue, forKey: "courtSide")
        }
    }
    
    var maxPlayers = 10001
    var progressUnlocked = true
    
    init() {
        if let playerIdStr = UserDefaults.standard.string(forKey: "playerId") {
            playerId = UUID(uuidString: playerIdStr)
        }
        else {
            playerId = nil
        }
        activeView = ActiveView(rawValue: UserDefaults.standard.integer(forKey: "activeView")) ??  .PlayerList
        courtSide =  CourtSide(rawValue: UserDefaults.standard.integer(forKey: "courtSide")) ?? .Near
        
        if UserDefaults.standard.bool(forKey: ProductId.Basic.text) {
            progressUnlocked = true
        }
        if UserDefaults.standard.bool(forKey: ProductId.Team.text) {
            progressUnlocked = true
            maxPlayers = 10001
        }
        if UserDefaults.standard.bool(forKey: ProductId.BasicToTeam.text) {
            maxPlayers = 10001
        }
    }
    
    func activateFeatures() {
        if UserDefaults.standard.bool(forKey: ProductId.Basic.text) {
            progressUnlocked = true
        }
        if UserDefaults.standard.bool(forKey: ProductId.Team.text) {
            progressUnlocked = true
            maxPlayers = 10001
        }
        if UserDefaults.standard.bool(forKey: ProductId.BasicToTeam.text) {
            maxPlayers = 10001
        }
    }
}

struct ErrorAlert: Identifiable {
    var id = UUID()
    var errorMessage: String
}

final class AppContext : ObservableObject {
    @Published var appSettings: AppSettings
    @Published var hideServeResultControlPanel = false
    @Published var sessionIdToDelete: UUID? = nil
    @Published var errorAlert: ErrorAlert?
    @Published var modalErrorMEssage: String = ""
    @Published var buttonWidth: CGFloat = 0.0
    
    init() {
        appSettings = AppSettings()
        hideServeResultControlPanel = false
    }
    
    func showError(_ message: String) {
        errorAlert = ErrorAlert(errorMessage: message)
    }
    
    func showError() {
        if !modalErrorMEssage.isEmpty {
            errorAlert = ErrorAlert(errorMessage: modalErrorMEssage)
            modalErrorMEssage = ""
        }
    }
}
