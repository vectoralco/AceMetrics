//
//  TennisCourt.swift
//
//  Created by Vijayakumar B on 08/03/21.
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

struct TennisCourtView : View {
    @EnvironmentObject var context: AppContext
    @ObservedObject var playerData: PlayerData
    @ObservedObject var serviceData: ServiceData
    @State private var player: Player? = nil
    
    private let court = CGSize(width:10.97, height:23.77)
    private let serviceBox = CGSize(width: 4.11, height: 6.4)
    private let backCourt = CGSize(width: 8.23, height: 5.49)
    private let doublesMargin:CGFloat = 1.37
    
    init(playerData: PlayerData, serviceData: ServiceData) {
        self.playerData = playerData
        self.serviceData = serviceData
    }
    
    var body: some View {
        ZStack {
            Color("rgbCourt").ignoresSafeArea()
            
            GeometryReader {
                geometry in
                
                let ratio = geometry.size.width/self.court.width
                
                Rectangle().stroke(Color.white, lineWidth:4)
                    .shadow(radius: 6)
                        
                Path {
                    path in
      
                    var x = ratio*self.doublesMargin
                    path.move(to: CGPoint(x:x, y:0))
                    path.addLine(to: CGPoint(x:x, y:geometry.size.height))
                    
                    x = geometry.size.width - ratio*self.doublesMargin
                    path.move(to: CGPoint(x:x, y:geometry.size.height))
                    path.addLine(to: CGPoint(x:x, y:0))
                    
                    var y = geometry.size.height/2
                    path.move(to: CGPoint(x:0, y:y))
                    path.addLine(to: CGPoint(x:geometry.size.width, y:y))
                    
                    x = ratio*doublesMargin
                    let lineLength = geometry.size.width - ratio*doublesMargin*2
                    
                    y = y - ratio * self.serviceBox.height
                    path.move(to: CGPoint(x:x, y:y))
                    path.addLine(to: CGPoint(x:x+lineLength, y:y))
                    
                    y = y + ratio * self.serviceBox.height*2
                    path.move(to: CGPoint(x:x, y:y))
                    path.addLine(to: CGPoint(x:x+lineLength, y:y))
                    
                    x = geometry.size.width/2
                    path.move(to: CGPoint(x:x, y:y))
                    path.addLine(to: CGPoint(x:x, y:y-ratio * self.serviceBox.height*2))
                }.stroke(lineWidth:4)
                 .foregroundColor(.white)
                
                if player?.isSessionActive() ?? false {
                    ServiceSessionPanels(ratio:ratio, playerData: self.playerData, serviceData: self.serviceData)
                        .environmentObject(context)
                }
            }.blur(radius: self.player?.isSessionActive() ?? false ? 0 : 5)
            .frame(minWidth: self.court.width, maxWidth: .infinity,
                    minHeight: self.court.height, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
            .aspectRatio(0.4615, contentMode: .fit)
            .background(Rectangle()
                            .fill(Color("rgbCourtCarpet"))
                            .shadow(radius: 2))
            .padding(.all)
        }.navigationBarTitle("", displayMode: .inline)
         .navigationBarHidden(true)
         .ignoresSafeArea(.keyboard)
         .onAppear {
             self.player = self.playerData.getPlayer(playerId: context.appSettings.playerId)
             if context.appSettings.playerId == nil && self.player != nil {
                 context.appSettings.playerId = self.player?.id ?? nil
             }
             if self.player == nil && !playerData.playerDictionary.isEmpty {
                 self.player = playerData.getFirstPlayer()
                 context.appSettings.playerId = self.player?.id ?? nil
             }
         }
         .onTapGesture {
             if self.serviceData.currentServicePlacement != nil {
                 self.serviceData.currentServicePlacement = nil
             }
         }
    }
}

struct ServiceSessionInactiveView : View {
    @EnvironmentObject var context : AppContext
    @ObservedObject var playerData : PlayerData
    @ObservedObject var serviceData: ServiceData
    @State private var player : Player?
    
    func startSession() {
        if !(player?.isSessionActive() ?? true) {
            if let error = serviceData.startSession(player: self.player) {
                context.showError("Data error\n" + error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack (spacing: 0) {
                Spacer()
                
                if !(player?.isSessionActive() ?? true) {
                    Button(action: { startSession() } ) {
                        ZStack {
                            Image(systemName: "play.fill")
                                .foregroundColor(Color("rgbCourtLightAccent"))
                                .font(.system(size: 40, weight: .medium))
                                .imageScale(.large)
                            Text("Start")
                                .hidden()
                        }
                    }.shadow(radius: 4.0)
                }
                
                Spacer()
            }
        }.onAppear {
            player = playerData.getPlayer(playerId: context.appSettings.playerId)
            if context.appSettings.playerId == nil && self.player != nil {
                context.appSettings.playerId = self.player?.id ?? nil
            }
            if self.player == nil && !playerData.playerDictionary.isEmpty {
                self.player = playerData.getFirstPlayer()
                context.appSettings.playerId = self.player?.id ?? nil
            }
        }
    }
}
