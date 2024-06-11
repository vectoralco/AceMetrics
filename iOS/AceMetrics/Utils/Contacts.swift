//
//  Contacts.swift
//
//  Created by Vijayakumar B on 05/02/22.
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

import Foundation
import Contacts

struct Contacts {
    static func checkContactsAccess() -> Bool {
        var authorized = false
        let contactStore = CNContactStore()
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
               case .authorized:
                   return true
               case .denied:
                   contactStore.requestAccess(for: .contacts) { granted, error in
                       authorized = granted
                   }
               case .restricted, .notDetermined:
                   contactStore.requestAccess(for: .contacts) { granted, error in
                       authorized = granted
                   }
               @unknown default:
                   return false
        }
        
        return authorized
    }
    
    static func getContactImage(firstName: String, lastName: String) -> Data? {
        var image: Data? = nil
        
        if Contacts.checkContactsAccess() {
            let predicate = CNContact.predicateForContacts(matchingName: firstName)
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataAvailableKey, CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
            
            do {
                image = nil
                let contacts = try CNContactStore().unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                for contact in contacts {
                    if contact.givenName == firstName &&
                        contact.familyName == lastName &&
                        contact.imageDataAvailable &&
                        contact.thumbnailImageData != nil {
                        image = contact.thumbnailImageData
                        break
                    }
                }
            } catch {
            }
        }
        
        return image
    }
}
