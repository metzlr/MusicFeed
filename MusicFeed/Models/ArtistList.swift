//
//  ArtistList.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 11/30/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation


class ArtistList: Equatable, Codable {
    static func == (lhs: ArtistList, rhs: ArtistList) -> Bool {
        return (lhs.name == rhs.name)
    }
    
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

    
    subscript(index: Int) -> Artist {
        return artists[index]
    }
    

}
