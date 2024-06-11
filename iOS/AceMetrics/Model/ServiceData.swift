//
//  ServiceData.swift
//
//  Created by Vijayakumar B on 07/03/21.
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

enum ServiceCourt : Int16, Codable, CaseIterable {
    case Ad=0, Deuce
    
    var text: String {
        switch self {
        case .Ad:
            return "Ad"
            
        case .Deuce:
            return "Deuce"
        }
    }
}

enum ServiceAction : Int16, Codable, CaseIterable {
    case First=0, Second
    
    mutating func toggle() {
        switch self {
        case .First:
            self = .Second
        case .Second:
            self = .First
        }
    }
    
    var text: String {
        switch self {
        case .First:
            return "First"
            
        case .Second:
            return "Second"
        }
    }
}

enum ServicePlacement: Int16, Codable, CaseIterable {
    case OutWide=0, Body, DownTheT
    
    var text : String {
        switch self {
        case .OutWide:
            return "Out wide"
            
        case .Body:
            return "Body"
            
        case .DownTheT:
            return "Down the T"
        }
    }
}

enum ServiceTarget: Int16, CaseIterable {
    case AdOutWide=0, AdBody, AdDownTheT, DeuceDownTheT, DeuceBody, DeuceOutWide
}

enum ServiceResult : Int16, Codable, CaseIterable {
    case Hit=0, OffTarget, Long, Wide, Net
    
    var text: String {
        switch self {
        case .Hit:
            return "Hit"
            
        case .OffTarget:
            return "Off Target"
            
        case .Long:
            return "Long"
            
        case .Wide:
            return "Wide"
            
        case .Net:
            return "Net"
        }
    }
    
    var color: Color {
        switch self {
        case .Hit:
            return Color("rgbBall")
            
        case .OffTarget:
            return Color("rgbBallYellow")
        
        default:
            return Color("rgbBallRed")
        }
    }
}

extension Service {
    var serviceRsultValue: ServiceResult {
        get {
            return ServiceResult(rawValue: self.result) ?? .OffTarget
        }
        set {
            self.result = newValue.rawValue
        }
    }
    
    var serviceActionValue: ServiceAction {
        get {
            return ServiceAction(rawValue: self.action) ?? .First
        }
        set {
            self.action = newValue.rawValue
        }
    }
}

struct ServiceTargetResult : Identifiable, Hashable {
    var action : ServiceAction
    var target: ServiceTarget
    var result: ServiceResult
    let count : Int
    let id = UUID()
}

extension ServiceSession {    
    var total : Int {
        get {
            services?.count ?? 0
        }
    }
    
    func total(action: ServiceAction?) -> Int {
        var count:Int = 0
        
        for service in services?.allObjects as? [Service] ?? [] {
            if service.action == action?.rawValue {
                count += 1
            }
        }
        
        return count
    }
    
    func maxPlacements(action: ServiceAction?) -> Int {
        var max:Int = 0
        var count:Int = 0
        let courts = ServiceCourt.allCases
        let placements = ServicePlacement.allCases
        
        for court in courts {
            for placement in placements {
                count = total(action: action, court: court, placement: placement)
                if count > max {
                    max = count
                }
            }
        }
        
        return max
    }
    
    func maxPlacements() -> Int {
        var max:Int = 0
        var count:Int = 0
        let courts = ServiceCourt.allCases
        let placements = ServicePlacement.allCases
        
        for court in courts {
            for placement in placements {
                count = total(action: .First, court: court, placement: placement) + total(action: .Second, court: court, placement: placement)
                if count > max {
                    max = count
                }
            }
        }
        
        return max
    }
    
    func totalHit(action: ServiceAction?) -> Int {
        var count:Int = 0
        
        for service in services?.allObjects as? [Service] ?? [] {
            if service.action == action?.rawValue && service.result == ServiceResult.Hit.rawValue {
                count += 1
            }
        }
        
        return count
    }
    
    func totalFault(action: ServiceAction?) -> Int {
        var count:Int = 0
        
        for service in services?.allObjects as? [Service] ?? [] {
            if service.action == action?.rawValue && service.result != ServiceResult.Hit.rawValue && service.result != ServiceResult.OffTarget.rawValue {
                count += 1
            }
        }
        
        return count
    }
    
    func total(action: ServiceAction?, court: ServiceCourt?, placement: ServicePlacement?) -> Int {
        var count:Int = 0
        
        for service in services?.allObjects as? [Service] ?? [] {
            if service.action == action?.rawValue && service.court == court?.rawValue && service.placement == placement?.rawValue {
                count += 1
            }
        }
        
        return count
    }
    
    func resultTotal(court: ServiceCourt?, action: ServiceAction?, placement: ServicePlacement?) -> (hitCount:Int, offTargetCount:Int, faultCount:Int, longCount:Int, wideCount:Int, netCount:Int) {
        var hitCount:Int = 0
        var offTargetCount:Int = 0
        var faultCount:Int = 0
        var longCount:Int = 0
        var wideCount:Int = 0
        var netCount:Int = 0
        
        for service in services?.allObjects as? [Service] ?? [] {
            if service.court == court?.rawValue && service.action == action?.rawValue && service.placement == placement?.rawValue {
                if (service.result == ServiceResult.Hit.rawValue) {
                    hitCount += 1
                }
                else if (service.result == ServiceResult.OffTarget.rawValue) {
                    offTargetCount += 1
                }
                else {
                    faultCount += 1
                    if (service.result == ServiceResult.Long.rawValue) {
                        longCount += 1
                    }
                    else if (service.result == ServiceResult.Wide.rawValue) {
                        wideCount += 1
                    }
                    if (service.result == ServiceResult.Net.rawValue) {
                        netCount += 1
                    }
                }
            }
        }
        
        return (hitCount, offTargetCount, faultCount, longCount, wideCount, netCount)
    }
    
    func resultTable(action: ServiceAction) -> [ServiceTargetResult] {
        var results: [ServiceTargetResult] = []
        var target: ServiceTarget
        
        for court in ServiceCourt.allCases {
            let placements : [ServicePlacement]
            if court == ServiceCourt.Ad {
                placements = ServicePlacement.allCases
                target = .AdOutWide
            } else {
                placements = ServicePlacement.allCases.reversed()
                target = .DeuceDownTheT
            }
            
            for  placement in placements {
                var hitCount = 0
                var longCount = 0
                var wideCount = 0
                var netCount = 0
                var offTargetCount = 0
                
                for service in services?.allObjects as? [Service] ?? [] {
                    if service.court == court.rawValue && service.action == action.rawValue && service.placement == placement.rawValue {
                        switch service.serviceRsultValue {
                            case .Hit:
                                hitCount += 1
                                
                            case .Long:
                                longCount += 1
                                
                            case .Wide:
                                wideCount += 1
                                
                            case .Net:
                                netCount += 1
                                
                            case .OffTarget:
                                offTargetCount += 1
                            }
                    }
                }
                                    
                var result = ServiceTargetResult(action: action, target: target, result: .Hit, count: hitCount)
                results.append(result)
                result = ServiceTargetResult(action: action, target: target, result: .Long, count: longCount)
                results.append(result)
                result = ServiceTargetResult(action: action, target: target, result: .Wide, count: wideCount)
                results.append(result)
                result = ServiceTargetResult(action: action, target: target, result: .Net, count: netCount)
                results.append(result)
                result = ServiceTargetResult(action: action, target: target, result: .OffTarget, count: offTargetCount)
                results.append(result)
                
                if target != .DeuceOutWide {
                    target = ServiceTarget(rawValue: target.rawValue + 1) ?? .DeuceOutWide
                }
            }
        }
        
        return results
    }
}

final class ServiceData : ObservableObject {
    @Published var serviceSession: ServiceSession? = nil
    @Published var currentServiceAction: ServiceAction = .First {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var currentServiceCourt: ServiceCourt? = nil
    @Published var currentServicePlacement: ServicePlacement? = nil
    private var viewContext = PersistenceController.shared.container.viewContext
    
    func startSession(player: Player?) -> Error? {
        serviceSession = ServiceSession(context: viewContext)
        serviceSession?.id = UUID()
        serviceSession?.name = String(localized: "New Session")
        serviceSession?.active = true
        serviceSession?.player = player
        serviceSession?.startTime = Date()
        currentServiceAction = .First
        
        if let session: ServiceSession = serviceSession {
            player?.sessionId = session.id
            player?.addToSessions(session)
            if let error = save() {
                return error
            }
        }
        
        return nil
    }
    
    func stopSession(player: Player?) -> Error? {
        if serviceSession != nil && serviceSession?.active ?? false {
            serviceSession?.active = false
            if let error = save() {
                return error
            }
        }
        
        player?.sessionId = nil
        serviceSession = nil
        currentServiceAction = .First
        
        return nil
    }
    
    func appendService(result: ServiceResult) -> Error? {
        if serviceSession != nil && currentServiceCourt != nil && currentServicePlacement != nil {
            let service = Service(context: viewContext)
            service.action = currentServiceAction.rawValue
            service.court = currentServiceCourt?.rawValue ?? ServiceCourt.Deuce.rawValue
            service.placement = currentServicePlacement?.rawValue ?? ServicePlacement.OutWide.rawValue
            service.result = result.rawValue
            service.index = Int16(truncatingIfNeeded: serviceSession?.services?.count ?? 0)
            serviceSession?.addToServices(service)
            
            currentServiceCourt = nil
            currentServicePlacement = nil
            
            return save()
        }
        
        return nil
    }
    
    func removeSession(player: Player?, session: ServiceSession) -> Error? {
        if player != nil{
            player?.removeFromSessions(session)
            viewContext.delete(session)
            return save()
        }
        
        return nil
    }
    
    func removeSession(player: Player?, sessionId: UUID?) -> Error? {
        if player != nil && sessionId != nil {
            if let session = getSession(sessionId: sessionId!) {
                if session.id == player?.sessionId {
                    player?.sessionId = nil
                }
                player?.removeFromSessions(session)
                viewContext.delete(session)
                return save()
            }
        }
        
        return nil
    }
    
    func getSession(sessionId: UUID) -> ServiceSession? {
        var session: ServiceSession? = nil
        
        viewContext.performAndWait {
            let fetchRequest = ServiceSession.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", sessionId as CVarArg)
            fetchRequest.fetchLimit = 1
            session = (try? fetchRequest.execute())?.first
        }
        
        return session
    }
    
    func loadActiveSession(sessionId : UUID?) {
        if let id = sessionId {
            if let session = getSession(sessionId: id) {
                if session.active {
                    self.serviceSession = session
                    if let serviceArray = self.serviceSession?.services?.allObjects as? [Service] {
                        if !serviceArray.isEmpty {
                            let services = serviceArray.sorted(by: { $0.index < $1.index })
                            self.currentServiceAction =  services[services.count - 1].serviceActionValue
                        }
                    }
                }
            }
        }
    }
    
    func undoService() -> Error? {
        if self.serviceSession?.active ?? false {
            if let serviceArray = self.serviceSession?.services?.allObjects as? [Service] {
                if !serviceArray.isEmpty {
                    let services = serviceArray.sorted(by: { $0.index < $1.index })
                    let service = services[services.count - 1]
                    if services.count > 1 {
                        self.currentServiceAction = services[services.count - 2].serviceActionValue
                    }
                    else {
                        self.currentServiceAction = .First
                    }
                    self.serviceSession?.removeFromServices(service)
                    viewContext.delete(service)
                    if let error = save() {
                        return error
                    }
                }
            }
        }
        
        return nil
    }
    
    private func save() -> Error? {
        do {
            try viewContext.save()
        } catch {
            return error
        }
        
        return nil
    }
}
