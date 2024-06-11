//
//  StoreView.swift
//
//  Created by Vijayakumar B on 26/03/22.
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

struct StoreView: View {
    @EnvironmentObject var context: AppContext
    @ObservedObject var store: Store
    @Binding var isPresented: Bool
    var closeButton: Bool = true
    var productIds:[ProductId]
    
    private func getProductTitle(productId: ProductId) -> String {
        if let product = store.getProduct(productId: productId.text) {
            if product.localizedTitle.isEmpty {
                return productId.title
            } else {
                return product.localizedTitle
            }
        }
        
        return productId.title
    }
    
    private func getProductDescription(productId: ProductId) -> String {
        if let product = store.getProduct(productId: productId.text) {
            if product.localizedDescription.isEmpty {
                return productId.description
            } else {
                return product.localizedDescription
            }
        }
        
        return productId.description
    }
    
    private func storeContents() -> some View {
        return ForEach(productIds, id: \.self) { productId in
            HStack (spacing: 0) {
                Text(getProductTitle(productId: productId))
                    .foregroundColor(.black)
                    .lexendFont(style: .body, weight: .regular)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 10)
                    .fixedSize(horizontal: true, vertical: false)
                
                Text(getProductDescription(productId: productId))
                    .foregroundColor(.black)
                    .lexendFont(style: .caption1, weight: .regular)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: {
                    if let product = store.getProduct(productId: productId.text) {
                        if store.transactionState != .purchasing {
                            store.purchaseProduct(product: product, completion: {context.appSettings.activateFeatures()})
                        }
                    }
                }) {
                    if let product = store.getProduct(productId: productId.text) {
                        Text(product.regularPrice.isEmpty ? "_._" : product.regularPrice)
                            .lexendFont(style: .body, weight: .regular)
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(minWidth: 60)
                    } else {
                        Text("_._")
                            .lexendFont(style: .body, weight: .regular)
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(minWidth: 60)
                    }
                }.background(ZStack {
                    Capsule().fill(Color("rgbGrayText"))
                }.shadow(radius: 2.0))
                .buttonStyle(.plain)
                .padding(.horizontal, 10)
            }.padding(.bottom, 10)
        }
    }
    
    var body: some View {
        if isPresented {
            VStack (spacing: 0) {
                HStack (alignment: .center) {
                    if closeButton {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .font(.system(.body))
                                .imageScale(.medium)
                        }.buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text("Upgrade with one time purchase")
                            .foregroundColor(.black)
                            .lexendFont(style: .body, weight: .regular)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    else {
                        Text("Upgrade with one time purchase")
                            .foregroundColor(.black)
                            .lexendFont(style: .body, weight: .regular)
                            .multilineTextAlignment(.center)
                    }
                }.padding(10)
                
                Divider()
                    .frame(height: 1)
                    .background(.black)
                    .padding(.bottom, 10)
                
                if store.products.isEmpty {
                    if store.timeOut {
                        storeContents()
                    }
                    else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                } else {
                    storeContents()
                    
                    Button(action: {
                        store.restoreProducts(completion: {context.appSettings.activateFeatures()})
                    }) {
                        Text("Restore purchases")
                            .lexendFont(style: .body, weight: .regular)
                            .foregroundColor(.white)
                            .padding(10)
                    }.background(ZStack {
                        Capsule().fill(Color("rgbGrayText"))
                    }.shadow(radius: 2.0))
                    .buttonStyle(.plain)
                    .padding(10)
                }
                
            }.background(ZStack {
                RoundedRectangle(cornerRadius: 10).fill(Color("rgbCourtLightAccent"))
            }.shadow(radius: 1.0))
            .padding()
            .onAppear {
                if store.products.isEmpty {
                    store.getProducts(productIds: context.appSettings.productIds)
                }
            }
        }
    }
}
