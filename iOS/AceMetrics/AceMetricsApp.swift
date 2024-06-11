//
//  AceMetricsApp.swift
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

@main
struct AceMetricsApp: App {
    @StateObject var context = AppContext()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(context)
                .alert(item: $context.errorAlert) { errorAlert in
                    Alert(title: Text("Error"), message: Text(errorAlert.errorMessage))
                }
        }
    }
}
