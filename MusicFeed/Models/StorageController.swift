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
    
    let authImplicit = OAuth2ImplicitGrant(settings: [
        "client_id": "08037a6d6c044109a99a46b267ed48f3",
        "keychain": false,
        "authorize_uri": "https://accounts.spotify.com/authorize",
        "scope": "user-follow-read",
        "redirect_uris": ["spotifyalert-rmg://oauth/callback"]
        ] as OAuth2JSON)
    
    var implicitAccessToken: String?
    
    //let loader: OAuth2DataLoader
    
    var artists = [Artist]()
    var releases = [Album]()
    var dateSortValue = TimeDuration.week
    var state: AppStatus = .rest
    
    //var netRequests = [AnyObject?]()
    let apiRequests: APICalls
    
    init() {
        apiRequests = APICalls()
        //loader = OAuth2DataLoader(oauth2: authClient)
        
    }
    
    func readArtistsFromFile(completion: @escaping () -> Void) {
        
        let pathDirectory = getDocumentsDirectory()
        try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
        let filePath = pathDirectory.appendingPathComponent("artists.json")
        
        guard let data = try? Data(contentsOf: filePath) else {
            print("Failed to get contents of artist file")
            return
        }
        
        artists = try! JSONDecoder().decode([Artist].self, from: data)
        
        self.apiRequests.getArtistImages(artists: artists) { [unowned self] artists in
            if artists.count > 0 {
                self.artists = artists
            }
            completion()
        }
        
        
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveArtistsToFile() {
        
        let pathDirectory = getDocumentsDirectory()
        try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
        let filePath = pathDirectory.appendingPathComponent("artists.json")
        
        let json = try? JSONEncoder().encode(artists)
        
        do {
            try json!.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }

    
}
