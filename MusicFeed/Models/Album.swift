//
//  Album.swift
//  SpotifyAlert
//
//  Created by Reed Metzler-Gilbertz on 8/8/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import UIKit


struct Album {
    
    let name: String
    let type: String
    let releaseDate: Date
    let datePrecision: String
    let totalTracks: Int
    let artists: [Artist]
    let urlImages: [SpotifyImage]
    
}

extension Album: Comparable, Equatable {
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
    static func < (lhs: Album, rhs: Album) -> Bool {
        return lhs.releaseDate > rhs.releaseDate
    }
    static func != (lhs: Album, rhs: Album) -> Bool {
        return lhs.name != rhs.name && lhs.type != rhs.type
    }
}


extension Album: Decodable {
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case name = "name"
        case releaseDate = "release_date"
        case totalTracks = "total_tracks"
        case datePrecision = "release_date_precision"
        
        case artists = "artists"
        case urlImages = "images"
        
    }
}


struct AlbumsWrapper: Decodable {
    
    let albums: [Album]
    
    enum CodingKeys: String, CodingKey {
        case albums = "items"
        
    }
    
}

struct AlbumsResource: ApiResource {
    
    var methodPath: String
    var httpMethod = "GET"
    var parameters = ["include_groups=album,single", "limit=7", "market=US"]
    
    init(artist: Artist) {
        methodPath = "artists/\(artist.id)/albums"
        
    }
    func makeModel(data: Data) -> [Album]? {
        let decoder = JSONDecoder()
        // If error comes up where it gets albums that dont have this format, I think its necessary to set up custom init(from: decoder) for Album to handle the different date precisions
        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
        do {
            let wrapped = try decoder.decode(AlbumsWrapper.self, from: data)
            return wrapped.albums
        } catch {
            print("DECODE ERROR")
            print(error)
            return nil
        }

    }
}


