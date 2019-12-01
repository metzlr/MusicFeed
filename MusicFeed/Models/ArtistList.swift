//
//  ArtistList.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 11/30/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation


class ArtistList: Codable {
    
    var name: String
    var artists = [Artist]()
    let canEdit: Bool
    
    init(name: String, canEdit: Bool = true) {
        self.name = name
        self.canEdit = canEdit
    }
    
    func removeArtist(artist: Artist) {
        guard let index = artists.firstIndex(of: artist) else {
            return
        }
        artists.remove(at: index)
    }

}
