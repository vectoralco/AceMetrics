//
//  ServeResultSummaryPanel.swift
//
//  Created by Vijayakumar B on 28/03/21.
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

struct ServiceSessionSummaryView : View {
    @EnvironmentObject var context : AppContext
    @ObservedObject var serviceData: ServiceData
    @State private var faultCircle: Bool = false
    @State private var inCircle: Bool = false
    @State private var hitCircle: Bool = false
    private var action: ServiceAction
    private var session: ServiceSession? = nil
    private var fontSize: CGFloat
    private var total: Int = 0
    private var hit: Int = 0
    private var servesIn: Int = 0
    private let formatter = NumberFormatter()
    
    init (action:ServiceAction, serviceData: ServiceData, session: ServiceSession? = nil, fontSize: CGFloat = 10.0) {
        self.action = action
        self.serviceData = serviceData
        self.session = session
        self.fontSize = fontSize
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        
        if session == nil {
            total = serviceData.serviceSession?.total(action: action) ?? 0
            hit = serviceData.serviceSession?.totalHit(action: action) ?? 0
            servesIn = total - (serviceData.serviceSession?.totalFault(action: action) ?? 0)
        } else {
            total = session?.total(action: action) ?? 0
            hit = session?.totalHit(action: action) ?? 0
            servesIn = total - (session?.totalFault(action: action) ?? 0)
        }
    }
    
    var body: some View {
        let hitPercent = Double(hit)/Double(total)*100
        let inPercent = Double(servesIn)/Double(total)*100
        
        VStack (spacing: 0) {
            if total != 0 {
            Text(self.action == ServiceAction.First ? "1st Serves" : "2nd Serves")
                .lexendFont(weight: .medium, size: fontSize+2)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: (fontSize+2)*3)
                
                if fontSize > 12 {
                    Spacer()
                }
                
                ZStack {
                    Circle()
                        .trim(from: 0, to: faultCircle ? 1 : 0)
                        .stroke(style: StrokeStyle(lineWidth: 10))
                        .foregroundColor(Color("rgbBallRed"))
                        .smallPadding()
                        .shadow(radius: 4.0)
                        .animation(Animation.linear(duration: 0.5), value: faultCircle)
                        .onAppear {
                            faultCircle = true
                        }
                    
                    Circle()
                        .trim(from: 0, to: inCircle ? CGFloat(inPercent)/100 : 0)
                        .stroke(style: StrokeStyle(lineWidth: 10))
                        .foregroundColor(Color("rgbBallYellow"))
                        .smallPadding()
                        .animation(Animation.linear(duration: 0.5), value: inCircle)
                        .onAppear {
                            inCircle = true
                        }
                    
                    Circle()
                        .trim(from: 0, to: hitCircle ? CGFloat(hitPercent)/100 : 0)
                        .stroke(style: StrokeStyle(lineWidth: 10))
                        .foregroundColor(Color("rgbBall"))
                        .smallPadding()
                        .animation(Animation.linear(duration: 0.5), value: hitCircle)
                        .onAppear {
                            hitCircle = true
                        }
                    
                    VStack {
                        Text("In")
                            .lexendFont(weight: .medium, size: fontSize)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        Text(String(formatter.string(from: inPercent as NSNumber) ?? "0") + "%")
                            .lexendFont(weight: .regular, size: fontSize)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Good")
                            .lexendFont(weight: .medium, size: fontSize)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        Text(String(formatter.string(from: hitPercent as NSNumber) ?? "0") + "%")
                            .lexendFont(weight: .regular, size: fontSize)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }.padding(UIDevice.current.userInterfaceIdiom == .phone ? 20 : 30)
                }
            }
            
            Spacer()
        }
    }
}

struct ServiceSessionSummaryPanel : View {
    @ObservedObject private var serviceData: ServiceData
    @State private var isShowingReport = false
    @State private var action : ServiceAction
    
    init (action: ServiceAction, serviceData: ServiceData) {
        self.action = action
        self.serviceData = serviceData
    }
    
    var body: some View {
        VStack {
            Spacer()
            if serviceData.serviceSession?.total(action: action) ?? 0 > 0 {
                GeometryReader { geometry in
                    let fontSize = geometry.size.width / 8
                    ServiceSessionSummaryView(action: action, serviceData: serviceData, fontSize: min(fontSize, 15))
                }
            }
            Spacer()
        }.padding(5)
        .onTapGesture {
            isShowingReport.toggle()
        }.sheet(isPresented: $isShowingReport) {
            if let session = serviceData.serviceSession {
                ServiceSessionReportSheet(isShowing: $isShowingReport, session: session, action: action)
            }
        }
    }
}
