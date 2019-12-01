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
    
    //var implicitAccessToken: String?
    
    var artists = [Artist]()
    var artistLists = [ArtistList]()
    
    
    var dateSortValue = TimeDuration.week
    var state: AppStatus = .rest
    
    let apiRequests: APICalls
    
    init() {
        apiRequests = APICalls()
        apiRequests.setDelegate(self)
        
        readArtistsFromFile()
        readArtistListsFromFile()
    
    }
    
    func readArtistsFromFile() {
        
        let pathDirectory = getDocumentsDirectory()
        try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
        let filePath = pathDirectory.appendingPathComponent("artists.json")
        
        guard let data = try? Data(contentsOf: filePath) else {
            print("Failed to get contents of artist file")
            return
        }
        
        artists = try! JSONDecoder().decode([Artist].self, from: data)
        
        /*
        let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
        self.apiRequests.getArtistImages(artists: artists, queue: queue) { [unowned self] artists in
            if artists.count > 0 {
                self.artists = artists
                
            }
            completion()
        }
        */
        
    }
    
    func readArtistListsFromFile() {
        
        let pathDirectory = getDocumentsDirectory()
        try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
        let filePath = pathDirectory.appendingPathComponent("artist_lists.json")
        
        guard let data = try? Data(contentsOf: filePath) else {
            print("Failed to get contents of artist list file")
            createAllArtistsList()
            return
        }
        
        self.artistLists = try! JSONDecoder().decode([ArtistList].self, from: data)
        
        
    }
    
    func createAllArtistsList() {
        if self.artistLists.count == 0 {
            self.artistLists.append(ArtistList(name: "All Artists", canEdit: false))
            for artist in self.artists {
                self.artistLists[0].artists.append(artist)
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveArtistsToFile() {
        self.artists.sort(by: {$0.name < $1.name})
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
    
    func saveArtistListsToFile() {
        let pathDirectory = getDocumentsDirectory()
        try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
        let filePath = pathDirectory.appendingPathComponent("artist_lists.json")
        
        let json = try? JSONEncoder().encode(artistLists)
        
        do {
            try json!.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }

    }
    
    func removeArtistFromLists(artist: Artist) {
        for list in self.artistLists {
            list.removeArtist(artist: artist)
        }
        /*
        let removedID = artist.id
        for i in 0..<self.artistLists.count {
            var list = artistLists[i]
            if (list.artistIDs.contains(removedID)) {
                var newIDs = [String]()
                for id in list.artistIDs {
                    if !(id == removedID) {
                        newIDs.append(id)
                    }
                }
                list.artistIDs = newIDs
            }
        }
        */
    }

    
}
