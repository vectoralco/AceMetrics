//
//  ServePanel.swift
//
//  Created by Vijayakumar B on 27/03/21.
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

struct ServePanel : View {
    @EnvironmentObject var context: AppContext
    @ObservedObject private var serviceData: ServiceData
    private let court: ServiceCourt

    init (court:ServiceCourt, serviceData: ServiceData) {
        self.serviceData = serviceData
        self.court = court
    }
    
    private func isSelected(_ placement: ServicePlacement) -> Bool {
        return serviceData.currentServicePlacement == placement  && serviceData.currentServiceCourt == self.court
    }
    
    private func getButtonImage(placement: ServicePlacement) -> String {
        let left:ServicePlacement
        
        if context.appSettings.courtSide == .Far {
            if self.court == ServiceCourt.Ad
            {
                left = ServicePlacement.DownTheT
            }
            else
            {
                left = ServicePlacement.OutWide
            }
        }
        else {
            if self.court == ServiceCourt.Ad
            {
                left = ServicePlacement.OutWide
            }
            else
            {
                left = ServicePlacement.DownTheT
            }
        }
        
        if placement == .Body {
            return "person.circle.fill"
        }
        
        if placement == .DownTheT {
            return "t.circle.fill"
        }
        
        if context.appSettings.courtSide == .Far {
            if placement == .OutWide && left == .OutWide {
                return "arrow.up.left.circle.fill"
            }
            else {
                return "arrow.up.right.circle.fill"
            }
        } else {
            if placement == .OutWide && left == .OutWide {
                return "arrow.down.left.circle.fill"
            }
            else {
                return "arrow.down.right.circle.fill"
            }
        }
    }
    
    private func drawGraph(hit: Int, offTarget: Int, fault: Int, max: Int) -> some View {
        GeometryReader {
            geometry in
            
            let percent:CGFloat = CGFloat(hit+offTarget+fault)/CGFloat(max)
            let hitPercent:CGFloat = CGFloat(hit)/CGFloat(hit+offTarget+fault)
            let offTargetPercent:CGFloat = CGFloat(offTarget)/CGFloat(hit+offTarget+fault)
            let faultPercent:CGFloat = CGFloat(fault)/CGFloat(hit+offTarget+fault)
            
            VStack (spacing: 0) {
                let gradient = Gradient(stops:
                [.init(color: Color("rgbBall"), location: 0),
                 .init(color: Color("rgbBall").opacity(0.5), location: hitPercent),
                 .init(color: Color(offTargetPercent+hitPercent != 0 ? "rgbBallYellow" : "rgbBallRed").opacity(0.5), location: hitPercent+offTargetPercent),
                 .init(color: Color("rgbBallRed"), location: offTargetPercent+hitPercent+faultPercent)])
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.clear)
                    .frame(height: (1.0-percent) * geometry.size.height)
                LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
                    .frame(height: percent * geometry.size.height)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
        }
    }
    
    private func showGraph(placement: ServicePlacement) -> some View {
        VStack (alignment: .center, spacing: 0, content: {
            if let totalPlacement = serviceData.serviceSession?.total(action: serviceData.currentServiceAction, court: court, placement: placement) {
                Text(totalPlacement <= 999 ? String(totalPlacement) : "")
                    .lexendFont(style: .caption2, weight: .medium)
                    .padding(.all, 0)
                    .opacity(totalPlacement>0 ? 1 : 0)
                    .foregroundColor(.white)
                Spacer()
                if let stats = serviceData.serviceSession?.resultTotal(court: court, action: serviceData.currentServiceAction, placement: placement) {
                    if let max = serviceData.serviceSession?.maxPlacements(action: serviceData.currentServiceAction) {
                        if max > 0 {
                            drawGraph(hit: stats.hitCount, offTarget: stats.offTargetCount, fault: stats.faultCount, max: max)
                                .shadow(radius: 2.0)
                        }
                    }
                }
            }
        })
    }
    
    private var left: ServicePlacement {
        if context.appSettings.courtSide == .Near {
            return court == .Ad ? .OutWide : .DownTheT
        }
        else {
            return court == .Ad ? .DownTheT : .OutWide
        }
    }
    
    private var right: ServicePlacement {
        if context.appSettings.courtSide == .Near {
            return court == .Ad ? .DownTheT : .OutWide
        }
        else {
            return court == .Ad ? .OutWide : .DownTheT
        }
    }
    
    private func buttonSizeInit() -> some View {
        return GeometryReader { (geometry) -> AnyView in
                let size = geometry.size
                DispatchQueue.main.async {
                    context.buttonWidth = size.width
                }
                return AnyView(Rectangle().fill(Color.clear)
                                .frame(width: 0, height: 0))
            }
    }
    
    var body: some View {
        HStack {
            VStack {
                if context.buttonWidth == 0 {
                    buttonSizeInit()
                }
                
                if context.appSettings.courtSide == .Near {
                    showGraph(placement: left)
                    Spacer()
                }
                
                Button(action: {
                    serviceData.currentServiceCourt = self.court
                    serviceData.currentServicePlacement = self.left
                }) {
                    Image(systemName: getButtonImage(placement: self.left))
                        .resizable()
                        .foregroundColor(self.isSelected(self.left) ? Color("rgbBall") : .white)
                        .font(Font.title.weight(.medium))
                        .imageScale(.medium)
                        .scaledToFit()
                }.shadow(radius: 2.0)
                .padding(.bottom, 2)
                
                if context.appSettings.courtSide == .Far {
                    Spacer()
                    showGraph(placement: left)
                }
            }
            
            Spacer()
            
            VStack {
                if context.appSettings.courtSide == CourtSide.Near {
                    showGraph(placement: .Body)
                    Spacer()
                }
                
                Button(action: {
                    serviceData.currentServiceCourt = self.court
                    serviceData.currentServicePlacement = .Body
                }) {
                    Image(systemName: getButtonImage(placement: ServicePlacement.Body))
                        .resizable()
                        .foregroundColor(self.isSelected(.Body) ? Color("rgbBall") : .white)
                        .font(Font.title.weight(.medium))
                        .imageScale(.medium)
                        .scaledToFit()
                }.shadow(radius: 2.0)
                .padding(.bottom, 2)
                
                if context.appSettings.courtSide == CourtSide.Far {
                    Spacer()
                    showGraph(placement: .Body)
                }
            }
            
            Spacer()
            
            VStack {
                if context.appSettings.courtSide == .Near {
                    showGraph(placement: right)
                    Spacer()
                }

                Button(action: {
                    serviceData.currentServiceCourt = self.court
                    serviceData.currentServicePlacement = self.right
                }) {
                    Image(systemName: getButtonImage(placement: right))
                        .resizable()
                        .foregroundColor(self.isSelected(self.right) ? Color("rgbBall") : .white)
                        .font(Font.title.weight(.medium))
                        .imageScale(.medium)
                        .scaledToFit()
                }.shadow(radius: 2.0)
                .padding(.bottom, 2)
                
                if context.appSettings.courtSide == .Far {
                    Spacer()
                    showGraph(placement: right)
                }
            }
            
        }.smallPadding()
    }
}
