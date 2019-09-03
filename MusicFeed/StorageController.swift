//
//  StorageController.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 8/31/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import OAuth2

class StorageController {
    
    let authClient = OAuth2ClientCredentials(settings:
        ["client_id": "08037a6d6c044109a99a46b267ed48f3",
        "client_secret": "3215b532acd94fd497f756f159aaa6c7",
        "authorize_uri": "https://accounts.spotify.com/api/token",
        "keychain": false
        ])
    let loader: OAuth2DataLoader
    
    init() {
        loader = OAuth2DataLoader(oauth2: authClient)
    }
    
}
