//
//  PlayerList.swift
//
//  Created by Vijayakumar B on 18/04/21.
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

struct WaitAnimation: View {
    @State private var animate = false
    
    var body: some View {
        Image("imgBallFilled")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .offset(y: animate ? -60 : 60)
            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animate)
            .onAppear {
                self.animate = true
            }
    }
}

struct PlayerListView : View {
    @EnvironmentObject var context: AppContext
    @State private var isShowingAddPlayer = false
    @ObservedObject var playerData: PlayerData
    @ObservedObject var store: Store
    @State private var selectedPlayer : Player? = nil
    @State private var showConfirmation = false
    @State private var playerToRemove : Player? = nil
    @State private var isShowingStore = false
    private var productIdTeam: [ProductId] = [ProductId.Team]
    private var productIdTeamUpgrade: [ProductId] = [ProductId.BasicToTeam]
    private var nameFormatter = PersonNameComponentsFormatter()

    init(playerData: PlayerData, store: Store) {
        self.playerData = playerData
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
       
        UITableView.appearance().separatorStyle = .singleLine
        UITableView.appearance().separatorColor = UIColor(Color("rgbCourtLightAccent"))
        UITableView.appearance().backgroundColor = UIColor(Color("rgbCourt"))
        UITableViewCell.appearance().backgroundColor = UIColor(Color("rgbCourtCarpet"))
        UITableView.appearance().tableFooterView = UIView()
        
        nameFormatter.style = .default
    }
    
    private func dismissUpdatePlayer() {
        selectedPlayer = nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("rgbCourt")
                List {
                    ForEach(playerData.playerDictionary.keys.sorted(), id:\.self) { key in
                        let players = playerData.playerDictionary[key]
                        Section(header: Text("\(key)").lexendFont(style: .body, weight: .medium)) {
                            ForEach (players!) { value in
                                HStack {
                                    if let components = nameFormatter.personNameComponents(from: "\(value.firstName ?? "") \(value.lastName ?? "")") {
                                        Text(nameFormatter.string(from: components))
                                            .foregroundColor(!value.hasSessions() && value.id != context.appSettings.playerId ? Color("rgbLightGrayText") : .white)
                                            .lexendFont(style: .body, weight: .medium)
                                            .onTapGesture {
                                                if let id = value.id {
                                                    selectedPlayer = playerData.getPlayer(playerId: id)
                                                }
                                            }
                                    }
                                    else {
                                        Text("\(value.firstName ?? "") \(value.lastName ?? "")")
                                            .foregroundColor(!value.hasSessions() && value.id != context.appSettings.playerId ? Color("rgbLightGrayText") : .white)
                                            .lexendFont(style: .body, weight: .medium)
                                            .onTapGesture {
                                                if let id = value.id {
                                                    selectedPlayer = playerData.getPlayer(playerId: id)
                                                }
                                            }
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if value.id != nil && context.appSettings.playerId != value.id {
                                                context.appSettings.playerId = value.id
                                                playerData.fetch()
                                            }
                                        }) {
                                        Image("imgBallFilled")
                                            .resizable()
                                            .scaledToFit()
                                            .saturation(value.id == context.appSettings.playerId ? 1.0 : 0.0)
                                    }.frame(maxHeight: 25)
                                    .padding(.trailing, 20)
                                    .buttonStyle(BorderlessButtonStyle())
                                    .shadow(radius: 2.0)
                        
                                }.listRowBackground(ZStack {
                                    Rectangle().fill(.black)
                                    Rectangle().fill(Color("rgbCourt").opacity(0.9))
                                })
                                .sheet (item: $selectedPlayer, onDismiss: dismissUpdatePlayer)  { player in
                                    UpdatePlayerSheet(playerData: playerData, player: player)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    if !value.hasSessions() && value.id != context.appSettings.playerId {
                                        Button(role: .destructive, action: {
                                            playerToRemove = value
                                            showConfirmation = true
                                        } ) {
                                            ZStack{
                                                Image(systemName: "minus.circle")
                                                    .resizable()
                                                    .font(Font.title.weight(.medium))
                                                    .imageScale(.medium)
                                                    .scaledToFit()
                                                Text("Remove Player")
                                                    .hidden()
                                            }
                                        }
                                    }
                                }
                                .confirmationDialog("Remove Player?", isPresented: $showConfirmation, titleVisibility: .visible) {
                                    if playerToRemove != nil {
                                        Button("Yes", role: .destructive) {
                                            if let error = playerData.removePlayer(playerId: playerToRemove?.id) {
                                                context.modalErrorMEssage = "Data error\n" + error.localizedDescription
                                            }
                                            playerToRemove = nil
                                        }
                                        Button("No") {}
                                    }
                                }.lexendFont(style: .body, weight: .medium)
                            }.shadow(radius: 2)
                        }.foregroundColor(Color("rgbGrayText"))
                        .lexendFont(style: .headline, weight: .medium)
                    }
                }.listStyle(GroupedListStyle())
                
                VStack {
                    Spacer()
                    if playerData.playerDictionary.isEmpty {
                        if playerData.fetchInProgress {
                            WaitAnimation()
                        }
                        else {
                            Text("Add a player profile to start")
                                .foregroundColor(Color("rgbGrayText"))
                                .lexendFont(style: .title3, weight: .regular)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    
                    if context.appSettings.maxPlayers <= 1 {
                        StoreView(store: store, isPresented: $isShowingStore, productIds: UserDefaults.standard.bool(forKey: ProductId.Basic.text) ? productIdTeamUpgrade : productIdTeam)
                    }
                    
                    HStack {
                        Button(action: { if playerData.playerCount >= context.appSettings.maxPlayers {
                                            isShowingStore.toggle()
                                        } else {
                                            isShowingAddPlayer.toggle()
                                        } } ) {
                            ZStack{
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .fixedSize()
                                    .foregroundColor(Color("rgbCourtLightAccent"))
                                    .background(Color("rgbCourtDarkAccent"))
                                    .clipShape(Circle())
                                    .font(.system(size: 40, weight: .medium))
                                    .imageScale(.large)
                                    
                                Text("Add Player")
                                    .hidden()
                            }
                        }.shadow(radius: 4.0)
                        .padding()
                        .disabled(playerData.playerCount > 10000)
                    }
                }
            }.navigationBarTitle("Players")
        }.navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $isShowingAddPlayer) {
            NewPlayerSheet(playerData: playerData, isShowing: $isShowingAddPlayer)
        }
        .refreshable {
            playerData.fetch()
        }
        .onAppear {
            var player = self.playerData.getPlayer(playerId: context.appSettings.playerId)
            if context.appSettings.playerId == nil && player != nil {
                context.appSettings.playerId = player?.id ?? nil
            }
            if player == nil && !playerData.playerDictionary.isEmpty {
                player = playerData.getFirstPlayer()
                context.appSettings.playerId = player?.id ?? nil
            }
        }
    }
}
