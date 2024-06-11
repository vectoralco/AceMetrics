//
//  ServeResultButtons.swift
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

struct ServeResultButtons : View {
    @EnvironmentObject var context: AppContext
    @ObservedObject var serviceData: ServiceData
    
    private func appendServe(result: ServiceResult) {
        if let error = serviceData.appendService(result: result) {
            context.showError("Data error\n" + error.localizedDescription)
        }
    }
    
    var body: some View {
        HStack (spacing: 0) {
            
            VStack (spacing: 0) {
                Text("In")
                    .foregroundColor(.white)
                    .lexendFont(weight: .medium, size: 14)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
                
                HStack (alignment: .top, spacing: 0) {
                    Button(action: {appendServe(result: ServiceResult.Hit)}) {
                        VStack (spacing: 0) {
                            Image("imgBallHit")
                                .resizable()
                                .scaledToFit()
                                .shadow(radius: 4.0)
                                .frame(height: max(context.buttonWidth, 40))
                            Text("Hit")
                                .foregroundColor(.white)
                                .lexendFont(weight: .medium, size: 10)
                                .multilineTextAlignment(.center)
                                .padding(.top, 5)
                        }
                    }.disabled(serviceData.currentServiceCourt == nil || serviceData.currentServicePlacement == nil )
                        .padding(5)

                    Button(action: {appendServe(result: ServiceResult.OffTarget)}) {
                        VStack (spacing: 0) {
                            let text = LocalizedStringKey("Off Target")
                            Image("imgBallOffTarget")
                                .resizable()
                                .scaledToFit()
                                .shadow(radius: 4.0)
                                .frame(height: max(context.buttonWidth, 40))
                            Text(text)
                                .foregroundColor(.white)
                                .lexendFont(weight: .medium, size: 10)
                                .multilineTextAlignment(.center)
                                .padding(.top, 5)
                        }
                    }.disabled(serviceData.currentServiceCourt == nil || serviceData.currentServicePlacement == nil)
                        .padding(5)
                }
            }.padding(.leading, 10)
            
            Spacer().frame(width: 10)
            
            VStack (spacing: 0) {
                Text("Fault")
                    .foregroundColor(.white)
                    .lexendFont(weight: .medium, size: 14)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
                
                HStack (alignment: .top, spacing: 0) {
                    Button(action: {appendServe(result: ServiceResult.Long)}) {
                        VStack (spacing: 0) {
                            Image("imgBallLong")
                                .resizable()
                                .scaledToFit()
                                .shadow(radius: 4.0)
                                .frame(height: max(context.buttonWidth, 40))
                            Text("Long")
                                .foregroundColor(.white)
                                .lexendFont(weight: .medium, size: 10)
                                .multilineTextAlignment(.center)
                                .padding(.top, 5)
                        }
                    }.disabled(serviceData.currentServiceCourt == nil || serviceData.currentServicePlacement == nil)
                        .padding(5)
                    
                    Button(action: {appendServe(result: ServiceResult.Wide)}) {
                        VStack (spacing: 0) {
                            Image("imgBallWide")
                                .resizable()
                                .scaledToFit()
                                .shadow(radius: 4.0)
                                .frame(height: max(context.buttonWidth, 40))
                            Text("Wide")
                                .foregroundColor(.white)
                                .lexendFont(weight: .medium, size: 10)
                                .multilineTextAlignment(.center)
                                .padding(.top, 5)
                        }
                    }.disabled(serviceData.currentServiceCourt == nil || serviceData.currentServicePlacement == nil)
                        .padding(5)
                    
                    Button(action: {appendServe(result:ServiceResult.Net)}) {
                        VStack (spacing: 0) {
                            Image("imgBallNet")
                                .resizable()
                                .scaledToFit()
                                .shadow(radius: 4.0)
                                .frame(height: max(context.buttonWidth, 40))
                            Text("Net")
                                .foregroundColor(.white)
                                .lexendFont(weight: .medium, size: 10)
                                .multilineTextAlignment(.center)
                                .padding(.top, 5)
                        }
                    }.disabled(serviceData.currentServiceCourt == nil || serviceData.currentServicePlacement == nil)
                        .padding(5)
                }
            }.padding(.trailing, 10)
            
        }.background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color("rgbCourtCarpet").opacity(0.9))
                        .blur(radius: 2))
        .fixedSize(horizontal: true, vertical: true)
        .padding(5)
    }
}
