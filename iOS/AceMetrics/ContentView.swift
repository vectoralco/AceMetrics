//
//  ContentView.swift
//  Created by Vijayakumar B on 06/10/21.
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
import StoreKit

struct ContentView: View {
    @EnvironmentObject var context: AppContext
    @StateObject var playerData: PlayerData = PlayerData()
    @StateObject var serviceData: ServiceData = ServiceData()
    @StateObject var store = Store()
    
    init() {
        UITabBar.appearance().barTintColor = UIColor(Color("rgbCourt"))
        UITabBar.appearance().tintColor = UIColor(Color("rgbCourt"))
        UITabBar.appearance().backgroundColor = UIColor(Color("rgbCourt"))
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color("rgbLightGrayText"))
        if NSLocale.current.languageCode == "ja" {
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(name: "NotoSansJP-Regular", size: 12)! ], for: .normal)
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(name: "Lexend-Regular", size: 12)! ], for: .normal)
        }
    }
    
    var body: some View {
        TabView(selection: $context.appSettings.activeView) {
            ZStack {
                PlayerListView(playerData: playerData, store: store)
                    .environmentObject(context)
            }.tabItem {
                VStack {
                    Image("symPlayers")
                        .resizable()
                        .imageScale(.medium)
                        .font(Font.title3.weight(.medium))
                        .scaledToFit()
                        .padding(2)
                    Text("Players")
                        .multilineTextAlignment(.center)
                }
            }.tag(ActiveView.PlayerList)
            
            ZStack {
                TennisCourtView(playerData: playerData, serviceData: serviceData)
                    .environmentObject(context)
                if !context.hideServeResultControlPanel {
                    ServiceSessionInactiveView(playerData: playerData, serviceData: serviceData)
                }
            }.tabItem {
                VStack {
                    Image("symTennisCourt")
                        .resizable()
                        .imageScale(.medium)
                        .font(Font.title3.weight(.medium))
                        .scaledToFit()
                        .padding(2)
                    Text("Session")
                        .multilineTextAlignment(.center)
                }
            }.tag(ActiveView.ServiceSession)
            .disabled(context.appSettings.playerId == nil)
            
            ZStack {
                StatsView(playerData: playerData, serviceData: serviceData, store: store)
                    .environmentObject(context)
            }.tabItem {
                VStack {
                    Image("symProgress")
                        .resizable()
                        .imageScale(.medium)
                        .font(Font.title3.weight(.medium))
                        .scaledToFit()
                        .padding(2)
                    Text("Progress")
                        .multilineTextAlignment(.center)
                }
            }.tag(ActiveView.Statistics)
        }.accentColor(.white)
        .onAppear {
            SKPaymentQueue.default().add(store)
            store.getProducts(productIds: context.appSettings.productIds)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
