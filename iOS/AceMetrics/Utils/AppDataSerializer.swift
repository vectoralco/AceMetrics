//
//  Util.swift
//
//  Created by Vijayakumar B on 01/10/21.
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

class AppDataSerializer<T : Codable> {
    private var fileName : String
    
    init(_ fileName: String) {
        self.fileName = fileName
    }
    
    private var documentsFolder : URL {
        do {
            return try FileManager.default.url (for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            fatalError("Cannot find documents directory.")
        }
    }
    
    private var fileURL : URL {
        return documentsFolder.appendingPathComponent(self.fileName)
    }
    
    func load() -> T? {
        guard let jsonData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        guard let data = try? JSONDecoder().decode(T.self, from: jsonData) else {
            fatalError("Cannot decode \(T.self)")
        }
        
        return data
    }
    
    func save(_ data : T) {
        guard let jsonData = try? JSONEncoder().encode(data) else {
            fatalError("Error encoding \(T.self)")
        }
        do {
            try jsonData.write(to: fileURL)
        } catch {
            fatalError("Unable to write \(T.self)")
        }
    }
}
