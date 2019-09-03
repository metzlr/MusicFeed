//
//  FirstViewController.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 8/31/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

//Sure Sure 1anAI9P9iSzc9qzLv6AtHZ
//Test token - BQDYHRJVXBYrfGRlPBCovgICVPjrDTBcL4Uf86WbRZgOwqToe-0nQ3izJ62eciGYGxxI5xH8PpJcAYafnFg


import UIKit

class FirstViewController: UIViewController {
    
    var request: AnyObject?
    var storageController: StorageController?

    override func viewDidLoad() {
        super.viewDidLoad()
        testArtistSearch()
        
    }
    func testAlbumRequest() {
        let artist = Artist(id: "1anAI9P9iSzc9qzLv6AtHZ", name: "Sure Sure")
        
        let resource = AlbumsResource(artist: artist)
        let request = ApiRequest(resource: resource, loader: storageController!.loader)
        self.request = request
        request.load() {
            albums in
            guard let albums = albums else {
                return
            }
            print(albums)
        }
        
    }
    func testArtistSearch() {
        
        let resource = ArtistSearchResource(searchText: "Sure Sure")
        let request = ApiRequest(resource: resource, loader: storageController!.loader)
        self.request = request
        request.load() {
            artists in
            guard let artists = artists else {
                return
            }
            print(artists)
        }
    }


}


extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
