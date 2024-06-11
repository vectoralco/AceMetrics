//
//  SessionSummary.swift
//
//  Created by Vijayakumar B on 04/04/21.
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

import SwiftUI

struct AdaptiveView<Content: View>: View {
    let content: () -> Content
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone {
                VStack(content: content)
            }
            else {
                HStack(alignment: .top, content: content)
            }
        }
    }
}

struct LineGraph: Shape {
    var points: [CGFloat]
    var closed = false
    
    func path(in rect: CGRect) -> Path {
        func point(at ix:  Int) -> CGPoint {
            let point = points[ix]
            let x = rect.width * CGFloat(ix) / CGFloat(points.count - 1)
            let y = (1 - point) * rect.height
            
            return CGPoint(x: x, y: y)
        }
        
        return Path { p in
            guard points.count > 1 else { return }
            
            let start = points[0]
            p.move(to: CGPoint(x: 0, y: (1 - start) * rect.height))
            
            for index in points.indices {
                p.addLine(to: point(at: index))
            }
            
            if closed {
                p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                p.closeSubpath()
            }
        }
    }
}

struct SessionSummary: View {
    @EnvironmentObject var context : AppContext
    @ObservedObject var serviceData: ServiceData
    private var session: ServiceSession
    private var firstServeTotal: Int
    private var secondServeTotal: Int
    @State private var expand = false
    
    init (serviceData: ServiceData, session: ServiceSession) {
        self.serviceData = serviceData
        self.session = session
        self.firstServeTotal = session.total(action: ServiceAction.First)
        self.secondServeTotal = session.total(action: ServiceAction.Second)
    }
    
    var body: some View {
        HStack {
            VStack (alignment: .center) {
                Spacer()
                VStack(spacing: 0) {
                    if let startTime = session.startTime {
                        Text(startTime.formatted(date: .abbreviated, time: .standard))
                            .foregroundColor(.white)
                            .lexendFont(style: .callout, weight: .medium)
                            .multilineTextAlignment(.center)
                    }
                    Text(self.session.name ?? "")
                        .foregroundColor(.white)
                        .lexendFont(style: .callout, weight: .medium)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                HStack {
                    if firstServeTotal != 0 {
                        resultView(action: ServiceAction.First)
                    }
                    if secondServeTotal != 0 {
                        resultView(action: ServiceAction.Second)
                    }
                }
                Spacer()
                if expand && context.sessionIdToDelete != session.id {
                    AdaptiveView {
                        Group {
                            if firstServeTotal != 0 {
                                VStack {
                                    Text("1st Serve Pattern")
                                        .lexendFont(style: .headline, weight: .medium)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 10)
                                    Divider()
                                        .frame(height: 2)
                                        .background(Color("rgbBall"))
                                        .padding(.horizontal, 10)
                                    SessionAnalysisReport(session: session, action: .First)
                                }.background(ZStack {
                                    RoundedRectangle(cornerRadius: 10).fill(.black)
                                    RoundedRectangle(cornerRadius: 10).fill(Color("rgbCourt").opacity(0.8))
                                }
                                .shadow(radius: 1.0))
                                .padding(.top, 10)
                                .fixedSize(horizontal: true, vertical: false)
                            }
                            
                            if secondServeTotal != 0 {
                                VStack {
                                    Text("2nd Serve Pattern")
                                        .lexendFont(style: .headline, weight: .medium)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 10)
                                    Divider()
                                        .frame(height: 2)
                                        .background(Color("rgbBall"))
                                        .padding(.horizontal, 10)
                                    SessionAnalysisReport(session: session, action: .Second)
                                }.background(ZStack {
                                    RoundedRectangle(cornerRadius: 10).fill(.black)
                                    RoundedRectangle(cornerRadius: 10).fill(Color("rgbCourt").opacity(0.8))
                                }
                                .shadow(radius: 1.0))
                                .padding(.top, 10)
                                .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                    }
                }
            }
        }.padding()
        .onTapGesture {
            expand.toggle()
        }
    }
    
    private func resultView(action: ServiceAction) -> some View {
        return HStack {
            Spacer()
            VStack {
                ServiceSessionSummaryView(action: action, serviceData: serviceData, session: session, fontSize: 14)
            }
            Spacer()
        }
    }
}

struct ServicePlacementTotal : View {
    private let imgName : String
    private var hitCount: Int = 0
    private var offTargetCount: Int = 0
    private var faultCount: Int = 0
    private var max: Int = 0
    
    init (sessions: [ServiceSession], court: ServiceCourt, placement: ServicePlacement, max: Int) {
        for session in sessions {
            let actions = ServiceAction.allCases
            for action in actions {
                let stats = session.resultTotal(court: court, action: action, placement: placement)
                hitCount += stats.hitCount
                offTargetCount += stats.offTargetCount
                faultCount += stats.faultCount
            }
        }
        
        self.max = max
        
        switch (placement) {
        case .OutWide:
            if (court == .Ad) {
                imgName = "arrow.down.left.circle"
            } else {
                imgName = "arrow.down.right.circle"
            }
            
        case .Body:
            imgName = "person.circle"
            
        case .DownTheT:
            imgName = "t.circle"
        }
    }
    
    func drawGraph(hit: Int, offTarget: Int, fault: Int, max: Int) -> some View {
        let percent:CGFloat = CGFloat(hit+offTarget+fault)/CGFloat(max)
        let hitPercent:CGFloat = CGFloat(hit)/CGFloat(hit+offTarget+fault)
        let offTargetPercent:CGFloat = CGFloat(offTarget)/CGFloat(hit+offTarget+fault)
        let faultPercent:CGFloat = CGFloat(fault)/CGFloat(hit+offTarget+fault)
        var stops: [Gradient.Stop] = []
        
        if faultPercent > 0 {
            stops.append(.init(color: Color("rgbBallRed").opacity(0.8), location: 0))
            if offTargetPercent == 0 && hitPercent == 0 {
                stops.append(.init(color: Color("rgbBallRed"), location: faultPercent))
            }
        }
        if offTargetPercent > 0 {
            stops.append(.init(color: Color("rgbBallYellow").opacity(0.8), location: faultPercent))
            if hitPercent == 0 {
                stops.append(.init(color: Color("rgbBallYellow"), location: faultPercent+offTargetPercent))
            }
        }
        if hitPercent > 0 {
            stops.append(.init(color: Color("rgbBall").opacity(0.8), location: faultPercent+offTargetPercent))
            stops.append(.init(color: Color("rgbBall"), location: hitPercent+faultPercent+offTargetPercent))
        }
        
        return ZStack {
            let gradient = Gradient(stops: stops)
            
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.white.opacity(percent > 0 ? 0.2 : 0), style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
            if percent > 0 {
                Circle()
                    .trim(from: 0, to: percent)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
                Circle()
                    .trim(from: 0, to: percent)
                    .stroke(AngularGradient(gradient: gradient, center: .center, startAngle: .degrees(0), endAngle: .degrees(360*percent)), style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
            }
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: imgName)
                .foregroundColor(.black)
                .font(Font.title3.weight(.medium))
                .imageScale(.large)
            ZStack {
                Text("\(hitCount+offTargetCount+faultCount)")
                    .foregroundColor(.black)
                    .lexendFont(style: .headline, weight: .regular)
                    .multilineTextAlignment(.center)
                    .padding(2)
                drawGraph(hit: hitCount, offTarget: offTargetCount, fault: faultCount, max: max)
            }
        }.padding(5)
        .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color("rgbCourtLightAccent")
                        .opacity(0.4))
                        .shadow(radius: 2))
    }
}

struct ProgressGraph: View {
    @EnvironmentObject var context : AppContext
    @Binding var sessions: [ServiceSession]
    private var max: Int = 0
    private var sessionHitPercent: [CGFloat] = []
    private var sessionInPercent: [CGFloat] = []
    
    init(sessions: Binding<[ServiceSession]>) {
        self._sessions = sessions
        
        var totals = [Int](repeating: 0, count: ServiceTarget.allCases.count)
        let courts = ServiceCourt.allCases
        let placements = ServicePlacement.allCases
        
        for session in self.sessions {
            for court in courts {
                for placement in placements {
                    let index = Int(court.rawValue) * ServicePlacement.allCases.count + Int(placement.rawValue)
                    totals[index] += session.total(action: .First, court: court, placement: placement)+session.total(action: .Second, court: court, placement: placement)
                    if totals[index] > max {
                        max = totals[index]
                    }
                }
            }
            
            let total = session.total(action: .First) + session.total(action: .Second)
            let hit = session.totalHit(action: .First) + session.totalHit(action: .Second)
            let fault = session.totalFault(action: .First) + session.totalFault(action: .Second)
            
            sessionHitPercent.append(Double(hit)/Double(total))
            sessionInPercent.append(Double(total-fault)/Double(total))
        }
        
        if sessions.count == 1 {
            sessionInPercent.append(sessionInPercent.last ?? 0)
            sessionHitPercent.append(sessionHitPercent.last ?? 0)
        }
        sessionHitPercent.reverse()
        sessionInPercent.reverse()
    }
    
    func drawCentreLine() -> some View {
        return HStack {
            Text("50%")
                .foregroundColor(.black)
                .lexendFont(style: .caption2, weight: .regular)
                .multilineTextAlignment(.center)
            GeometryReader {
                geometry in
                Path {
                    path in
      
                    path.move(to: CGPoint(x:0, y:geometry.size.height/2))
                    path.addLine(to: CGPoint(x:geometry.size.width, y:geometry.size.height/2))
                }.stroke(style: StrokeStyle(lineWidth: 0.5, dash: [2]))
                .foregroundColor(.black)
            }
        }
    }
    
    var progressLineGraph: some View {
        VStack {
            VStack (spacing: 0) {
                Text("In")
                    .foregroundColor(.black)
                    .lexendFont(style: .callout, weight: .medium)
                    .multilineTextAlignment(.center)
                ZStack {
                    drawCentreLine()
                    LinearGradient(gradient: Gradient(colors: [Color("rgbBallYellow").opacity(0.8), Color("rgbBallYellow").opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                        .clipShape(LineGraph(points: sessionInPercent, closed: true))
                    LineGraph(points: sessionInPercent)
                        .stroke(Color("rgbBallYellow"), lineWidth: 2)
                }.frame(height: 100)
            }.background(Color("rgbCourtLightAccent").opacity(0.2))
            
            VStack (spacing: 0) {
                Text("Good")
                    .foregroundColor(.black)
                    .lexendFont(style: .callout, weight: .medium)
                    .multilineTextAlignment(.center)
                ZStack {
                    drawCentreLine()
                    LinearGradient(gradient: Gradient(colors: [Color("rgbBall").opacity(0.8), Color("rgbBall").opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                        .clipShape(LineGraph(points: sessionHitPercent, closed: true))
                    LineGraph(points: sessionHitPercent)
                        .stroke(Color("rgbBall"), lineWidth: 2)
                }.frame(height: 100)
            }.background(Color("rgbCourtLightAccent").opacity(0.2))
            .padding(.top, 10)
        }
    }
    
    var distributionChart: some View {
        VStack {
            HStack {
                HStack {
                    Spacer()
                    Text("Ad Court")
                        .foregroundColor(.black)
                        .lexendFont(style: .headline, weight: .medium)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: true, vertical: false)
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Text("Deuce Court")
                        .foregroundColor(.black)
                        .lexendFont(style: .headline, weight: .medium)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: true, vertical: false)
                    Spacer()
                }
            }.padding(.top, 5)
            
            HStack {
                Spacer()
                
                ServicePlacementTotal(sessions: sessions, court: .Ad, placement: .OutWide, max: max)
                    
                ServicePlacementTotal(sessions: sessions, court: .Ad, placement: .Body, max: max)

                ServicePlacementTotal(sessions: sessions, court: .Ad, placement: .DownTheT, max: max)

                Spacer()
                
                ServicePlacementTotal(sessions: sessions, court: .Deuce, placement: .DownTheT, max: max)
                
                ServicePlacementTotal(sessions: sessions, court: .Deuce, placement: .Body, max: max)
                
                ServicePlacementTotal(sessions: sessions, court: .Deuce, placement: .OutWide, max: max)
                
                Spacer()
            }.padding(.bottom, 10)
            
        }.background(Color("rgbCourtLightAccent").opacity(0.2))
    }
    
    var body: some View {
        VStack {
            progressLineGraph
                .padding(5)
            distributionChart
                .padding(5)
        }.fixedSize(horizontal: true, vertical: false)
    }
}

struct StatsView: View {
    @EnvironmentObject var context : AppContext
    @ObservedObject var playerData : PlayerData
    @ObservedObject var serviceData : ServiceData
    @ObservedObject var store: Store
    @State private var player: Player?
    @State private var sessions: [ServiceSession] = []
    @State private var image: Data? = nil
    @State private var isShowingStore: Bool
    @State private var sessionRange: Float
    private var productIds: [ProductId] = []
    private var nameFormater = PersonNameComponentsFormatter()
    
    init(playerData: PlayerData, serviceData: ServiceData, store: Store) {
        self.playerData = playerData
        self.serviceData = serviceData
        self.store = store
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color("rgbCourt"))
        if NSLocale.current.languageCode == "ja" {
            appearance.largeTitleTextAttributes = [.font: UIFont(name: "NotoSansJP-Regular", size: 34)!, .foregroundColor: UIColor.white]
            appearance.titleTextAttributes = [.font: UIFont(name: "NotoSansJP-Regular", size: 20)!, .foregroundColor: UIColor.white]
        } else {
            appearance.largeTitleTextAttributes = [.font: UIFont(name: "Lexend-Bold", size: 34)!, .foregroundColor: UIColor.white]
            appearance.titleTextAttributes = [.font: UIFont(name: "Lexend-Bold", size: 20)!, .foregroundColor: UIColor.white]
        }
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        isShowingStore = false
        productIds.append(ProductId.Basic)
        productIds.append(ProductId.Team)
        
        nameFormater.style = .default
        
        self.sessionRange = 60
    }
    
    private func updateSessions() {
        self.sessions = player?.sessions?.allObjects as? [ServiceSession] ?? []
        
        self.sessions.sort {
            $0.startTime ?? Date() > $1.startTime ?? Date()
        }
        
        if sessionRange < 60 {
            let slice = self.sessions.prefix(Int(sessionRange))
            self.sessions = [ServiceSession](slice)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("rgbCourt").ignoresSafeArea()
                
                VStack (spacing: 0) {
                    HStack {
                        if self.image != nil {
                            Image(uiImage: UIImage(data: self.image ?? Data()) ?? UIImage())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.white, lineWidth: 2))
                                .padding(10)
                        }
                        VStack {
                            if let components = nameFormater.personNameComponents(from: "\(self.player?.firstName ?? "") \(self.player?.lastName ?? "")") {
                                Text(nameFormater.string(from: components))
                                    .foregroundColor(.white)
                                    .lexendFont(style: .title3, weight: .medium)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }.padding(.top, 10)
                    
                    if self.sessions.count > 0 {
                        VStack {
                            Slider(value: Binding(get: {
                                                        self.sessionRange
                                                    }, set: { (newVal) in
                                                        self.sessionRange = newVal
                                                        updateSessions()
                                                    }),
                                   in: 10...60, step: 10) {
                            } minimumValueLabel: {
                                Text("10")
                                    .foregroundColor(.white)
                                    .lexendFont(style: .callout, weight: .medium)
                                    .multilineTextAlignment(.center)
                            } maximumValueLabel: {
                                Text("Max")
                                    .foregroundColor(.white)
                                    .lexendFont(style: .callout, weight: .medium)
                                    .multilineTextAlignment(.center)
                            } onEditingChanged: { _ in
                            }.accentColor(Color("rgbCourtDarkAccent"))
                            .padding(.top, 10)
                            .padding(.horizontal, 10)
                            
                            Text(self.sessionRange > 50 ? NSLocalizedString("All Sessions", comment: "") : String(format: NSLocalizedString("Last %d Sessions", comment: ""),Int(self.sessionRange)))
                                .foregroundColor(.white)
                                .lexendFont(style: .callout, weight: .medium)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 10)
                        }.background(ZStack {
                            RoundedRectangle(cornerRadius: 20).fill(.black)
                            RoundedRectangle(cornerRadius: 20).fill(Color("rgbCourt").opacity(0.9))
                            }.shadow(radius: 1))
                        .padding()
                    }
                    
                    ScrollView {
                        if self.sessions.count > 0 {
                            VStack (spacing: 0){
                                Text("Summary")
                                    .foregroundColor(.white)
                                    .lexendFont(style: .headline, weight: .medium)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 10)
                                ProgressGraph(sessions: $sessions)
                                    .padding(10)
                            }.background(ZStack {
                                RoundedRectangle(cornerRadius: 10).fill(.black)
                                RoundedRectangle(cornerRadius: 10).fill(Color("rgbCourt").opacity(0.8))
                            }.shadow(radius: 1.0))
                            .blur(radius: !context.appSettings.progressUnlocked && sessionRange > 10 ? 5 : 0)
                            .padding()
                        }
                        
                        if !sessions.isEmpty {
                            VStack {
                                ForEach(sessions, id: \.id) { session in
                                    VStack {
                                        SessionSummary(serviceData: serviceData, session: session)
                                            .contextMenu {
                                                
                                                Button (role: .destructive) {
                                                    if let error = serviceData.removeSession(player: player, session: session) {
                                                        context.showError("Data error\n" + error.localizedDescription)
                                                    }
                                                    updateSessions()
                                                } label: {
                                                    Label("Delete", systemImage: "minus.circle")
                                                        .font(Font.body.weight(.medium))
                                                        .background(Color("rgbCourtLightAccent").opacity(0.9))
                                                    
                                                }
                                                Button {
                                                } label: {
                                                    Label("Cancel", systemImage: "xmark.circle")
                                                        .labelStyle(.titleOnly)
                                                        .font(Font.body.weight(.medium))
                                                        .background(Color("rgbCourtLightAccent").opacity(0.9))
                                                    
                                                }
                                                
                                            }
                                    }.background(ZStack {
                                        RoundedRectangle(cornerRadius: 10).fill(.black)
                                        RoundedRectangle(cornerRadius: 10).fill(Color("rgbCourt").opacity(0.9))
                                    }.shadow(radius: 1.0))
                                    .padding()
                                    .disabled(!context.appSettings.progressUnlocked && sessionRange > 10)
                                }
                            }.blur(radius: !context.appSettings.progressUnlocked && sessionRange > 10 ? 5 : 0)
                        }
                    }
                }
                
                if !context.appSettings.progressUnlocked && sessionRange > 10 {
                    Spacer()
                    StoreView(store: store, isPresented: $isShowingStore, closeButton: false, productIds: productIds)
                }
            }.navigationTitle("Progress")
        }.navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.player = playerData.getPlayer(playerId: context.appSettings.playerId)
            if context.appSettings.playerId == nil && self.player != nil {
                context.appSettings.playerId = self.player?.id ?? nil
            }
            if self.player == nil && !playerData.playerDictionary.isEmpty {
                self.player = playerData.getFirstPlayer()
                context.appSettings.playerId = self.player?.id ?? nil
            }
            if self.player != nil {
                updateSessions()
                self.image = Contacts.getContactImage(firstName: self.player?.firstName ?? "", lastName: self.player?.lastName ?? "")
            }
            
            isShowingStore = !context.appSettings.progressUnlocked
            
            if !context.appSettings.progressUnlocked {
                self.sessionRange = 10
            }
        }
    }
}
