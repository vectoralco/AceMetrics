//
//  PlayerNameEntry.swift
//
//  Created by Vijayakumar B on 23/03/21.
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

struct PlayerEntry: View {
    @EnvironmentObject var context : AppContext
    @Binding var firstName : String
    @Binding var lastName : String
    @Binding var playingHand : PlayingHand
    @State internal var rightHander = true
    @State internal var image: Data? = nil
    @State private var typing = false
    @State private var nameFormatter = PersonNameComponentsFormatter()
    
    var body: some View {
        VStack {
            ZStack {
                if image != nil && !typing {
                    Image(uiImage: UIImage(data: image ?? Data()) ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
                else {
                    if !firstName.isEmpty && !typing {
                        if let components = nameFormatter.personNameComponents(from: "\(firstName) \(lastName)") {
                            Text(nameFormatter.string(from: components))
                                .foregroundColor(.white)
                                .lexendFont(weight: .medium, size: 40)
                                .frame(width: 100, height: 100)
                                .background(
                                    Circle()
                                        .strokeBorder(.white, lineWidth: 2)
                                        .background(Circle().foregroundColor(Color("rgbCourtDarkAccent")))
                                )
                        }
                    }
                }
            }.padding()
            
            VStack {
                ZStack {
                    if firstName.isEmpty {
                        Text("First name")
                            .foregroundColor(Color("rgbHintText"))
                            .lexendFont(style: .body, weight: .medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                            .padding(.top, 20)
                    }
                    TextField("", text: $firstName, onEditingChanged: {
                            self.typing = $0
                        })
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .lexendFont(style: .body, weight: .medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .padding(.top, 20)
                        .onSubmit {
                            image = Contacts.getContactImage(firstName: firstName, lastName: lastName)
                        }
                }
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                    .padding(.horizontal, 10)
                
                ZStack {
                    if lastName.isEmpty {
                        Text("Last name")
                            .foregroundColor(Color("rgbHintText"))
                            .lexendFont(style: .body, weight: .medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                            .padding(.top, 20)
                    }
                    TextField("", text: $lastName, onEditingChanged: {
                        self.typing = $0
                        })
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .lexendFont(style: .body, weight: .medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .padding(.top, 20)
                        .onSubmit {
                            image = Contacts.getContactImage(firstName: firstName, lastName: lastName)
                        }
                }
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
            }.background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20).fill(.black)
                    RoundedRectangle(cornerRadius: 20).fill(Color("rgbCourt").opacity(0.9))
                }.shadow(radius: 1)
            )
            .padding()
            
            HStack {
                Text("Left hander")
                    .foregroundColor(.white)
                    .opacity(rightHander ? 0.0 : 1.0)
                    .lexendFont(style: .body, weight: .medium)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
                    .padding(.leading, 20)
                
                Toggle("Playing Hand", isOn: $rightHander)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    .accentColor(Color("rgbCourtDarkAccent"))
                    .background(Capsule().fill(Color("rgbCourtDarkAccent")))
                    .onChange(of: rightHander) { value in
                        playingHand = value ? PlayingHand.Right : PlayingHand.Left
                    }
                
                Text("Right hander")
                    .foregroundColor(.white)
                    .opacity(rightHander ? 1.0 : 0.0)
                    .lexendFont(style: .body, weight: .medium)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
                    .padding(.trailing, 20)
            }.background(ZStack {
                RoundedRectangle(cornerRadius: 20).fill(.black)
                RoundedRectangle(cornerRadius: 20).fill(Color("rgbCourt").opacity(0.9))
                }.shadow(radius: 1)
            )
            .padding()
            .onAppear {
                self.rightHander = playingHand == PlayingHand.Right
            }
        }.fixedSize(horizontal: true, vertical: false)
        .onAppear(perform: { image = Contacts.getContactImage(firstName: firstName, lastName: lastName)
            nameFormatter.style = .abbreviated
        })
    }
}

struct FirstPlayerEntry: View {
    @EnvironmentObject var context: AppContext
    @ObservedObject var playerData: PlayerData
    @State private var firstName : String = ""
    @State private var lastName : String = ""
    @State private var playingHand : PlayingHand = PlayingHand.Right
    
    var body: some View {
        ZStack {
            Color("rgbCourt").ignoresSafeArea()
            VStack {
                Spacer()
                Text("New Player")
                    .foregroundColor(.black)
                    .lexendFont(style: .title3, weight: .medium)
                    .multilineTextAlignment(.center)
                Spacer()
                PlayerEntry(firstName: $firstName, lastName: $lastName, playingHand: $playingHand)
                Spacer()
                Button(action: {
                    let player = playerData.newPlayer()
                    player.firstName = firstName
                    player.lastName = lastName
                    player.playingHandValue = playingHand
                    if let error = playerData.save() {
                        context.showError("Data error\n" + error.localizedDescription)
                    }
                    context.appSettings.playerId = player.id
                } ) {
                    Text("Start")
                        .lexendFont(style: .body, weight: .medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 10)
                }.background(ZStack {
                    Capsule().fill(Color("rgbCourtDarkAccent"))
                }.shadow(radius: 2.0))
                .disabled(self.firstName.isEmpty || playerData.findPlayer(firstName: firstName, lastName: lastName))
                .buttonStyle(.plain)
                Spacer()
            }
        }
    }
}

struct NewPlayerSheet: View {
    @EnvironmentObject var context: AppContext
    @ObservedObject var playerData: PlayerData
    @Binding var isShowing : Bool
    @State private var firstName : String = ""
    @State private var lastName : String = ""
    @State private var playingHand : PlayingHand = PlayingHand.Right
    
    init(playerData: PlayerData, isShowing: Binding<Bool>) {
        self.playerData = playerData
        self._isShowing = isShowing
    }
    
    var body: some View {
        ZStack {
            Color("rgbCourt").ignoresSafeArea()
            
            VStack {
                HStack (alignment: .center) {
                    Button(action: { isShowing = false }) {
                        Text("Cancel")
                            .lexendFont(style: .body, weight: .regular)
                            .foregroundColor(.white)
                    }.padding(.horizontal, 20)
                    .padding(.top, 20)
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("New Player")
                        .padding(.top, 20)
                        .foregroundColor(.black)
                        .lexendFont(style: .title3, weight: .medium)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button(action: {
                        let firstPlayer = playerData.playerDictionary.isEmpty
                        let player = playerData.newPlayer()
                        player.firstName = self.firstName
                        player.lastName = self.lastName
                        player.playingHandValue = self.playingHand
                        if let error = playerData.save() {
                            context.modalErrorMEssage = "Data error\n" + error.localizedDescription
                        }
                        if firstPlayer {
                            context.appSettings.playerId = player.id
                        }
                        isShowing = false
                    } ) {
                        Text("Add")
                            .lexendFont(style: .body, weight: .regular)
                            .foregroundColor(.white)
                    }.padding(.horizontal, 20)
                    .padding(.top, 20)
                    .buttonStyle(.plain)
                    .disabled(self.firstName.isEmpty || playerData.findPlayer(firstName: firstName, lastName: lastName))
                }
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                
                Spacer()
                
                PlayerEntry(firstName: $firstName, lastName: $lastName, playingHand: $playingHand)
                
                Spacer()
            }
        }
    }
}

struct UpdatePlayerSheet: View {
    @Environment (\.presentationMode) var presentationMode
    @EnvironmentObject var context : AppContext
    @ObservedObject var playerData: PlayerData
    @ObservedObject var player : Player
    @State private var firstName : String = ""
    @State private var lastName : String = ""
    @State private var playingHand: PlayingHand = PlayingHand.Right

    init(playerData: PlayerData, player: Player) {
        self.playerData = playerData
        self.player = player
    }
    
    var body: some View {
        ZStack {
            Color("rgbCourt").ignoresSafeArea()
            
            VStack {
                HStack (alignment: .center) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Cancel")
                            .lexendFont(style: .body, weight: .regular)
                            .foregroundColor(.white)
                    }.padding(.horizontal, 20)
                    .padding(.top, 20)
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button(action: {
                        if !self.firstName.isEmpty {
                            if !playerData.findPlayer(firstName: firstName, lastName: lastName) {
                                self.player.firstName = self.firstName
                                self.player.lastName = self.lastName
                            }
                            self.player.playingHandValue = self.playingHand
                            if let error = playerData.save() {
                                context.modalErrorMEssage = "Data error\n" + error.localizedDescription
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                    } ) {
                        Text("Done")
                            .lexendFont(style: .body, weight: .regular)
                            .foregroundColor(.white)
                    }.padding(.horizontal, 20)
                    .padding(.top, 20)
                    .buttonStyle(.plain)
                    .disabled(self.firstName.isEmpty)
                }
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                
                Spacer()
                
                PlayerEntry(firstName: $firstName, lastName: $lastName, playingHand: $playingHand)
                
                Spacer()
            }
        }.onAppear {
            if (player.firstName ?? "").isEmpty {
                presentationMode.wrappedValue.dismiss()
            } else {
                self.firstName = player.firstName ?? ""
                self.lastName = player.lastName ?? ""
                self.playingHand = player.playingHandValue
            }
        }
    }
}
