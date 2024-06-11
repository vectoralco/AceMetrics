//
//  CourtContent.swift
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

struct ServiceProgress : View {
    @ObservedObject private var serviceData: ServiceData
    
    init(serviceData: ServiceData) {
        self.serviceData = serviceData
    }
    
    var body : some View {
        ScrollView(.horizontal) {
            ScrollViewReader { scrollView in
                if let services = serviceData.serviceSession?.services?.allObjects as? [Service] {
                    
                LazyHStack (alignment: .top, spacing: 1) {
                    ForEach(services.sorted(by: {$0.index < $1.index}), id: \.index) {service in
                            ZStack {
                                Circle()
                                    .fill(service.serviceRsultValue.color)
                                    .frame(width: 10, height: 10, alignment: .leading)
                                    .id(service.index)
                            }
                        }
                    
                    Circle()
                        .fill(.clear)
                        .frame(width: 10, height: 10, alignment: .leading)
                        .id(10000)
                    
                    Spacer()
                }.padding(.leading, 10.0)
                 .frame(maxHeight: 20)
                 .onChange(of: serviceData.serviceSession?.services?.count) { _ in
                     scrollView.scrollTo(10000, anchor: .trailing)
                 }
                 .onAppear {
                     scrollView.scrollTo(10000, anchor: .trailing)
                 }
                    
                }
            }
        }
    }
}

struct ServeSelectionPanel : View {
    @ObservedObject private var serviceData: ServiceData
    
    init (serviceData: ServiceData) {
        self.serviceData = serviceData
    }
    
    var body: some View {
        VStack (spacing: 0.0, content: {
            VStack {
                Text(serviceData.currentServiceAction.text + " serve")
                    .foregroundColor(.white)
                    .lexendFont(weight: .regular, size: 12)
                    .multilineTextAlignment(.center)
                if serviceData.currentServiceCourt != nil {
                    Text(serviceData.currentServiceCourt?.text ?? "" + " court")
                        .foregroundColor(.white)
                        .lexendFont(weight: .regular, size: 12)
                        .multilineTextAlignment(.center)
                }
                Text(serviceData.currentServicePlacement?.text ?? "")
                    .foregroundColor(.white)
                    .lexendFont(weight: .regular, size: 12)
                    .multilineTextAlignment(.center)
            }.padding(5)
        }).padding(.horizontal, 5)
    }
}

struct ServiceSessionPanels : View {
    @EnvironmentObject var context: AppContext
    @ObservedObject private var playerData: PlayerData
    @ObservedObject private var serviceData: ServiceData
    @State private var player: Player? = nil
    @State private var showConfirmation = false
    @State private var sessionName: String = ""
    @State private var playerProfilePicture: Data? = nil
    
    private let court = CGSize(width:10.97, height:23.77)
    private let serviceBox = CGSize(width: 4.11, height: 6.4)
    private let backCourt = CGSize(width: 8.23, height: 5.49)
    private let doublesMargin:CGFloat = 1.37
    private let ratio:CGFloat
    private let doublesAlleySize : CGSize
    private let serviceBoxSize : CGSize
    private let backCourtSize : CGSize
    private let courtSize : CGSize
    private var nameFormater = PersonNameComponentsFormatter()
    
    init(ratio: CGFloat, playerData: PlayerData, serviceData: ServiceData) {
        self.ratio = ratio
        self.playerData = playerData
        self.serviceData = serviceData
        
        doublesAlleySize = CGSize(width: self.ratio*self.doublesMargin, height: ratio*court.height/2)
        serviceBoxSize = CGSize(width:self.ratio*serviceBox.width, height:ratio*serviceBox.height)
        backCourtSize = CGSize(width:self.ratio*backCourt.width, height:ratio*backCourt.height)
        courtSize = CGSize(width:self.ratio*court.width, height:ratio*court.height)
    }
    
    var body : some View {
        ZStack {
            VStack (spacing: 0) {
                showCourtTop()
                showCourtBottom()
            }.frame(maxWidth:.infinity, maxHeight: .infinity)
        }.onAppear {
            if playerData.playerDictionary.isEmpty {
                context.appSettings.activeView = .PlayerList
            } else {
                self.player = playerData.getPlayer(playerId: context.appSettings.playerId)
                if self.player == nil && !playerData.playerDictionary.isEmpty {
                    self.player = playerData.getFirstPlayer()
                    context.appSettings.playerId = self.player?.id ?? nil
                }
                if player?.isSessionActive() ?? false {
                    serviceData.loadActiveSession(sessionId: player?.sessionId)
                }
                playerProfilePicture = Contacts.getContactImage(firstName: player?.firstName ?? "", lastName: player?.lastName ?? "")
                self.sessionName = serviceData.serviceSession?.name ?? ""
            }
        }
    }
    
    private func showCourtTop () -> some View {
        return VStack (spacing: 0) {
            HStack (spacing: 0) {
                VStack (spacing: 0) {
                    Spacer()
                }.frame(width: doublesAlleySize.width)
                
                ZStack {
                    showSessionInfo(compact: backCourtSize.height < 120)
                }.frame(width: backCourtSize.width, height: backCourtSize.height)
                
                VStack (spacing: 0) {
                    Spacer()
                }.frame(width: doublesAlleySize.width)
            }.frame(width: courtSize.width, height: backCourtSize.height)
            
            ZStack {
                HStack (spacing: 0) {
                    VStack (spacing: 0) {
                        Spacer()
                    }.frame(width: doublesAlleySize.width)
                    
                    VStack (spacing: 0) {
                        HStack (spacing: 0) {
                            if context.appSettings.courtSide == CourtSide.Far {
                                if serviceData.serviceSession?.active ?? false {
                                    ZStack {
                                        ServePanel(court: ServiceCourt.Deuce, serviceData: serviceData)
                                    }.frame(width:serviceBoxSize.width, height:serviceBoxSize.height)
                                        .disabled(serviceData.currentServicePlacement != nil)
                                    
                                    ZStack {
                                        ServePanel(court: ServiceCourt.Ad, serviceData: serviceData)
                                    }.frame(width:serviceBoxSize.width, height:serviceBoxSize.height)
                                        .disabled(serviceData.currentServicePlacement != nil)
                                }
                            }
                            else {
                                ZStack {
                                    if serviceData.serviceSession?.active ?? false {
                                        ServiceSessionSummaryPanel(action: ServiceAction.First, serviceData: serviceData)
                                    }
                                }.frame(width:serviceBoxSize.width, height:serviceBoxSize.height)
                                
                                ZStack {
                                    if serviceData.serviceSession?.active ?? false {
                                        ServiceSessionSummaryPanel(action: ServiceAction.Second, serviceData: serviceData)
                                    }
                                }.frame(width:serviceBoxSize.width, height:serviceBoxSize.height)
                            }
                        }
                    }.frame(width: backCourtSize.width, height: serviceBoxSize.height)
                    
                    VStack (spacing: 0) {
                        Button {
                            if context.appSettings.courtSide == .Far {
                                serviceData.currentServiceAction.toggle()
                            }
                            else {
                                context.appSettings.courtSide.toggle()
                                serviceData.currentServiceAction = serviceData.currentServiceAction
                            }
                        } label: {
                            VStack {
                                Image("imgBallFilled")
                                    .resizable()
                                    .scaledToFit()
                                    .saturation(context.appSettings.courtSide == .Far && serviceData.currentServiceAction == .Second ? 1.0 : 0)
                                    .frame(maxWidth: context.buttonWidth)
                                Image("imgBallFilled")
                                    .resizable()
                                    .scaledToFit()
                                    .saturation(context.appSettings.courtSide == .Far ? 1.0 : 0)
                                    .frame(maxWidth: context.buttonWidth)
                                    .offset(y: -20)
                            }
                        }.shadow(radius: 2.0)
                        .padding(5)
                        
                        Spacer()
                    }.frame(width: doublesAlleySize.width, height: serviceBoxSize.height)
                }.frame(width: courtSize.width, height: serviceBoxSize.height)
                .disabled(serviceData.currentServicePlacement != nil)
                
                VStack {
                    if context.appSettings.courtSide == CourtSide.Far {
                        if serviceData.serviceSession?.active ?? false && serviceData.currentServicePlacement != nil {
                            ServeResultButtons(serviceData: serviceData).padding(.top, backCourtSize.width/6)
                            Spacer()
                        }
                    }
                }
            }.frame(width: courtSize.width, height: serviceBoxSize.height)
        }.frame(maxWidth: courtSize.width, maxHeight:  courtSize.height/2)
    }
    
    private func showCourtBottom () -> some View {
        return VStack (spacing: 0) {
            HStack (spacing: 0) {
                VStack (spacing: 0) {
                    Spacer()
                }.frame(width: doublesAlleySize.width)
                
                HStack (spacing: 0) {
                    if context.appSettings.courtSide == CourtSide.Near {
                        if serviceData.serviceSession?.active ?? false {
                            ZStack {
                                ServePanel(court: ServiceCourt.Ad,  serviceData: serviceData)
                            }.frame(width:serviceBoxSize.width, height:serviceBoxSize.height)
                                .disabled(serviceData.currentServicePlacement != nil)
                            
                            ZStack {
                                ServePanel(court: ServiceCourt.Deuce, serviceData: serviceData)
                            }.frame(width:serviceBoxSize.width, height:serviceBoxSize.height)
                                .disabled(serviceData.currentServicePlacement != nil)
                        }
                    }
                    else {
                        ZStack {
                            if serviceData.serviceSession?.active ?? false {
                                ServiceSessionSummaryPanel(action: ServiceAction.First, serviceData: serviceData)
                            }
                        }.frame(width:serviceBoxSize.width, height:serviceBoxSize.height)
                        
                        ZStack {
                            if serviceData.serviceSession?.active ?? false {
                                ServiceSessionSummaryPanel(action: ServiceAction.Second, serviceData: serviceData)
                            }
                        }.frame(width:serviceBoxSize.width, height:serviceBoxSize.height)
                    }
                }.frame(width: backCourtSize.width, height: serviceBoxSize.height)
                
                VStack (spacing: 0) {
                    Spacer()
                    
                    Button {
                        if context.appSettings.courtSide == .Near {
                            serviceData.currentServiceAction.toggle()
                        }
                        else {
                            context.appSettings.courtSide.toggle()
                            serviceData.currentServiceAction = serviceData.currentServiceAction
                        }
                    } label: {
                        VStack {
                            Image("imgBallFilled")
                                .resizable()
                                .scaledToFit()
                                .saturation(context.appSettings.courtSide == .Near && serviceData.currentServiceAction == .Second ? 1.0 : 0)
                                .frame(maxWidth: context.buttonWidth)
                                .offset(y: 20)
                            Image("imgBallFilled")
                                .resizable()
                                .scaledToFit()
                                .saturation(context.appSettings.courtSide == .Near ? 1.0 : 0)
                                .frame(maxWidth: context.buttonWidth)
                        }
                    }.shadow(radius: 2.0)
                    .padding(5)
                }.frame(width: doublesAlleySize.width, height: serviceBoxSize.height)
            }.frame(width: courtSize.width, height: serviceBoxSize.height)
            .disabled(serviceData.currentServicePlacement != nil)
            
            ZStack {
                HStack (spacing: 0) {
                    VStack (spacing: 0) {
                        Spacer()
                        if player?.isSessionActive() ?? false &&
                            serviceData.currentServicePlacement == nil {
                            Button(action: { if serviceData.serviceSession?.total ?? 0 == 0 {
                                                stopSession()
                                            } else {
                                                self.showConfirmation = true
                                            }
                                    }) {
                                        Image(systemName: "stop.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .fixedSize()
                                            .foregroundColor(Color("rgbCourtLightAccent"))
                                            .background(Color("rgbCourtDarkAccent"))
                                            .clipShape(Circle())
                                            .font(.system(size: 40, weight: .medium))
                                            .imageScale(.large)
                                    }.disabled(!(player?.isSessionActive() ?? false))
                                    .padding(.bottom, 10)
                                    .shadow(radius: 4.0)
                                    .confirmationDialog("Stop session?", isPresented: self.$showConfirmation, titleVisibility: .visible) {
                                        Button("Yes", role: .destructive) { stopSession() }
                                        Button("No") {}
                                    }.lexendFont(style: .body, weight: .medium)
                                }
                    }.frame(width: doublesAlleySize.width)
                    
                    ZStack  {
                        VStack (spacing: 0) {
                            if serviceData.serviceSession?.active ?? false {
                                    ServiceProgress(serviceData: serviceData)
                                    .padding(.top, 10)
                                    .padding(.horizontal, 10)
                            }
                            Spacer()
                        }
                    }.frame(maxWidth: backCourtSize.width, maxHeight: backCourtSize.height)
                    
                    VStack (spacing: 0) {
                        Spacer()
                        if player?.isSessionActive() ?? false &&
                            serviceData.currentServicePlacement == nil {
                            Button(action: { if let error = serviceData.undoService() {
                                context.showError("Data error\n" + error.localizedDescription)
                                }
                                }) {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .fixedSize()
                                    .foregroundColor(Color("rgbCourtLightAccent"))
                                    .background(Color("rgbCourtDarkAccent"))
                                    .clipShape(Circle())
                                    .font(.system(size: 40, weight: .medium))
                                    .imageScale(.large)
                            }.disabled(!(player?.isSessionActive() ?? false))
                            .padding(.bottom, 10)
                            .shadow(radius: 4.0)
                        }
                    }.frame(width: doublesAlleySize.width)
                }.frame(width: courtSize.width, height: backCourtSize.height)
                
                VStack {
                    Spacer()
                    if context.appSettings.courtSide == CourtSide.Near {
                        if serviceData.serviceSession?.active ?? false && serviceData.currentServicePlacement != nil {
                            ServeResultButtons(serviceData: serviceData)
                        }
                    }
                }
            }.frame(width: courtSize.width, height: backCourtSize.height)
        }.frame(maxWidth: courtSize.width, maxHeight: courtSize.height/2)
    }
    
    private func showSessionInfo (compact: Bool) -> some View {
        if compact {
            nameFormater.style = .abbreviated
        } else {
            nameFormater.style = .default
        }
        
        return VStack (spacing: 0) {
            Spacer()
            if serviceData.serviceSession?.active ?? false {
                HStack {
                    if playerProfilePicture != nil && !compact {
                        Image(uiImage: UIImage(data: playerProfilePicture ?? Data()) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 20, idealWidth: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                            .padding(10)
                    }
                    VStack {
                        if let components = nameFormater.personNameComponents(from: "\(self.player?.firstName ?? "") \(self.player?.lastName ?? "")") {
                            Text(nameFormater.string(from: components))
                                .foregroundColor(.white)
                                .titleFont()
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                Divider()
                    .frame(height: 2)
                    .background(Color("rgbBall"))
                    .padding(.horizontal, 20)
                
                Text(serviceData.serviceSession?.active ?? false ? "Service session" : "")
                    .foregroundColor(.black)
                    .headlineFont()
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
                
                Spacer()

                VStack(spacing: 0) {
                    if let startTime = serviceData.serviceSession?.startTime {
                        Text(serviceData.serviceSession?.active ?? false ? startTime.formatted(date: .abbreviated, time: .standard) : "")
                            .foregroundColor(.white)
                            .headlineFont()
                            .multilineTextAlignment(.center)
                    }
                    TextField("", text:$sessionName,
                        onEditingChanged: {
                            (editingChanged) in
                            if editingChanged {
                                context.hideServeResultControlPanel = true
                            }
                            else {
                                context.hideServeResultControlPanel = false
                            }
                        },
                        onCommit: {
                            if sessionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                serviceData.serviceSession?.name = String(localized: "New Session")
                            } else {
                                serviceData.serviceSession?.name = sessionName
                            }
                        })
                        .foregroundColor(.white)
                        .headlineFont()
                        .multilineTextAlignment(.center)
                }
            }
            Spacer()
        }
    }
    
    private func stopSession() {
        if self.player?.isSessionActive() ?? false {
            if self.serviceData.serviceSession?.total == 0 {
                if let error = self.serviceData.removeSession(player: self.player, sessionId: self.player?.sessionId) {
                    context.showError("Data error\n" + error.localizedDescription)
                }
            }
            
            if let error = self.serviceData.stopSession(player: self.player) {
                context.showError("Data error\n" + error.localizedDescription)
            }
        }
    }
}
