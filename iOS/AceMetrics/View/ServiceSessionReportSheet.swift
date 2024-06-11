//
//  ServiceReport.swift
//
//  Created by Vijayakumar B on 27/10/21.
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

struct ServiceResultTitle : View {
    private let imgName : String
    private let total: Int
    private let hitCount: Int
    private let offTargetCount: Int
    private let faultCount: Int
    private let max: Int
    @State private var alpha: Double = 0
    
    init (session: ServiceSession, action: ServiceAction, court: ServiceCourt, placement: ServicePlacement) {
        let stats = session.resultTotal(court: court, action: action, placement: placement)
        max = session.maxPlacements(action: action)
        hitCount = stats.hitCount
        offTargetCount = stats.offTargetCount
        faultCount = stats.faultCount
        total = hitCount + offTargetCount + faultCount
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
                Text("\(total)")
                    .foregroundColor(.black).opacity(alpha)
                    .lexendFont(style: .headline, weight: .regular)
                    .multilineTextAlignment(.center)
                    .padding(2)
                    .animation(Animation.linear(duration: 1), value: alpha)
                    .onAppear {
                        alpha = total == 0 ? 0 : 1
                    }
                drawGraph(hit: hitCount, offTarget: offTargetCount, fault: faultCount, max: max)
            }
        }.padding(5)
        .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color("rgbCourtLightAccent")
                        .opacity(0.4))
                        .shadow(radius: 2))
    }
}

struct ServiceResultCell : View {
    private let total: Int
    @State private var alpha: Double = 0
    
    init (total: Int) {
        self.total = total
    }
    
    var body: some View {
        ZStack {
            Image(systemName: "circle")
                .foregroundColor(.black).opacity(0)
                .font(.system(.title3))
                .imageScale(.large)
            Text("\(total)")
                .foregroundColor(.white).opacity(alpha)
                .lexendFont(style: .headline, weight: .medium)
                .multilineTextAlignment(.center)
                .padding(.top, 2)
                .animation(Animation.linear(duration: 1), value: alpha)
                .onAppear {
                    alpha = total == 0 ? 0 : 1
                }
        }.padding(5)
    }
}

struct SessionAnalysisReport : View {
    private var session : ServiceSession
    private var action: ServiceAction
    private var hitTotal : Int
    private var faultTotal: Int
    private var longFault = false
    private var wideFault = false
    private var netFault  = false
    private var total: Int
    private var resultReport: [ServiceTargetResult]
    @State var rowWidth: CGFloat = 0
    
    init (session: ServiceSession, action: ServiceAction) {
        self.session = session
        self.action = action
        self.total = session.total(action: action)
        self.hitTotal = session.totalHit(action: action)
        self.faultTotal = session.totalFault(action: action)
        self.resultReport = session.resultTable(action: action)
        
        if self.faultTotal != 0 {
            for result in self.resultReport {
                if result.result == .Long  && result.count != 0 {
                    longFault = true
                }
                if result.result == .Wide && result.count != 0 {
                    wideFault = true
                }
                if result.result == .Net && result.count != 0 {
                    netFault = true
                }
                
                if longFault && wideFault && netFault {
                    break
                }
            }
        }
    }
    
    var body : some View {
        VStack {
            
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
                    
                    ServiceResultTitle(session: session, action: action, court: .Ad, placement: .OutWide)
                        
                    ServiceResultTitle(session: session, action: action, court: .Ad, placement: .Body)

                    ServiceResultTitle(session: session, action: action, court: .Ad, placement: .DownTheT)

                    Spacer()
                    
                    ServiceResultTitle(session: session, action: action, court: .Deuce, placement: .DownTheT)
                    
                    ServiceResultTitle(session: session, action: action, court: .Deuce, placement: .Body)
                    
                    ServiceResultTitle(session: session, action: action, court: .Deuce, placement: .OutWide)
                    
                    Spacer()
                }.padding(.bottom, 10)
                
            }.background(Color("rgbCourtLightAccent").opacity(0.2))
            .fixedSize(horizontal: true, vertical: true)
            
            if hitTotal != 0 {
                
                VStack {
                    
                    Text("Good serves, on-target")
                        .foregroundColor(.black)
                        .lexendFont(style: .headline, weight: .medium)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                    
                    HStack {
                        Spacer()
                        ForEach(ServiceTarget.allCases, id: \.self) { target in
                            ForEach(resultReport, id: \.self) { result in
                                if result.target == target && result.result == .Hit {
                                    ServiceResultCell(total: result.count)
                                        .background(RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color("rgbBall")
                                                        .opacity(0.4))
                                                        .shadow(radius: 2))
                                }
                            }
                            
                            if target == .AdDownTheT {
                                Spacer()
                            }
                        }
                        Spacer()
                    }.padding(.bottom, 10)
                    
                }.background(Color(.white).opacity(0.2)
                                .overlay(Color("rgbBall").opacity(0.2)))
                .fixedSize(horizontal: true, vertical: false)
                
            }
            
            if hitTotal+faultTotal != total {
                
                VStack {
                        Text("Serves in, missed target")
                            .foregroundColor(.black)
                            .lexendFont(style: .headline, weight: .medium)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                    
                    HStack {
                        Spacer()
                        ForEach(ServiceTarget.allCases, id: \.self) { target in
                            ForEach(resultReport, id: \.self) { result in
                                if result.target == target && result.result == .OffTarget {
                                    ServiceResultCell(total: result.count)
                                        .background(RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color("rgbBallYellow")
                                                        .opacity(0.6))
                                                        .shadow(radius: 2))
                                }
                            }
                            
                            if target == .AdDownTheT {
                                Spacer()
                            }
                        }
                        Spacer()
                    }.padding(.bottom, 10)
                    
                }.background(Color(.white).opacity(0.1)
                                .overlay(Color("rgbBallYellow").opacity(0.4)))
                .fixedSize(horizontal: true, vertical: false)
                
            }
            
            if faultTotal != 0 {
                
                VStack {
                    Text("Faults")
                        .foregroundColor(.black)
                        .lexendFont(style: .headline, weight: .medium)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                    Divider()
                        .frame(height: 1)
                        .background(Color("rgbGrayText"))
                    
                    if longFault {
                        VStack {
                            HStack {
                                Text("Long")
                                    .foregroundColor(.black)
                                    .lexendFont(style: .headline, weight: .medium)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 2)
                                    .frame(maxWidth: .infinity)
                            }
                                
                            HStack {
                                Spacer()
                                ForEach(ServiceTarget.allCases, id: \.self) { target in
                                    ForEach(resultReport, id: \.self) { result in
                                        if result.target == target && result.result == .Long {
                                            ServiceResultCell(total: result.count)
                                                .background(RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color("rgbBallRed")
                                                                .opacity(0.5))
                                                                .shadow(radius: 2))
                                        }
                                    }
                                    
                                    if target == .AdDownTheT {
                                        Spacer()
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    if wideFault {
                        VStack {
                            HStack {
                                Text("Wide")
                                    .foregroundColor(.black)
                                    .lexendFont(style: .headline, weight: .medium)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 2)
                                    .frame(maxWidth: .infinity)
                            }
                                
                            HStack {
                                Spacer()
                                
                                ForEach(ServiceTarget.allCases, id: \.self) { target in
                                    ForEach(resultReport, id: \.self) { result in
                                        if result.target == target && result.result == .Wide {
                                            ServiceResultCell(total: result.count)
                                                .background(RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color("rgbBallRed")
                                                                .opacity(0.5))
                                                                .shadow(radius: 2))
                                        }
                                    }
                                    
                                    if target == .AdDownTheT {
                                        Spacer()
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    if netFault {
                        VStack {
                            HStack {
                                Text("Net")
                                    .foregroundColor(.black)
                                    .lexendFont(style: .headline, weight: .medium)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 2)
                                    .frame(maxWidth: .infinity)
                            }
                                
                            HStack {
                                Spacer()
                                
                                ForEach(ServiceTarget.allCases, id: \.self) { target in
                                    ForEach(resultReport, id: \.self) { result in
                                        if result.target == target && result.result == .Net {
                                            ServiceResultCell(total: result.count)
                                                .background(RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color("rgbBallRed")
                                                                .opacity(0.5))
                                                                .shadow(radius: 2))
                                        }
                                    }
                                    
                                    if target == .AdDownTheT {
                                        Spacer()
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 10)
                }.background(Color(.white).opacity(0.2)
                                .overlay(Color("rgbBallRed").opacity(0.4)))
                .fixedSize(horizontal: true, vertical: false)
                
            }
        }.padding(10)
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct ServiceSessionReportSheet: View {
    @Binding var isShowing : Bool
    private var session: ServiceSession
    private var action: ServiceAction

    init (isShowing: Binding<Bool>, session: ServiceSession, action: ServiceAction) {
        self._isShowing = isShowing
        self.session = session
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Color("rgbCourt").ignoresSafeArea()
            
            ScrollView {
                HStack (alignment: .center) {
                    Button(action: { isShowing = false }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("rgbCourtLightAccent"))
                            .font(.system(.title3))
                            .imageScale(.large)
                    }.buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(action == .First ?  "1st Serve Pattern" : "2nd Serve Pattern")
                        .foregroundColor(.white)
                        .lexendFont(style: .title3, weight: .medium)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }.padding(.horizontal, 20)
                .padding(.top, 20)
                
                Divider()
                    .frame(height: 1)
                    .background(.white)
                    .padding(.bottom, 10)
                
                SessionAnalysisReport(session: session, action: action).background(ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(.black)
                    RoundedRectangle(cornerRadius: 10).fill(Color("rgbCourt").opacity(0.9))
                }.shadow(radius: 1.0))
                .padding()
            }
        }
    }
}

