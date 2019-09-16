//
//  Album.swift
//  SpotifyAlert
//
//  Created by Reed Metzler-Gilbertz on 8/8/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import UIKit
import OAuth2


struct Album {
    
    let name: String
    let type: String
    let releaseDate: Date
    let datePrecision: String
    let totalTracks: Int
    let externalURL: String
    var artists: [Artist]
    var urlImages: [SpotifyImage]
    //var smallImageData: Data?
    var largeImageData: Data?
    
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


extension Album: Codable {
    enum CodingKeys: String, CodingKey {
        case type = "album_type"
        case name = "name"
        case releaseDate = "release_date"
        case totalTracks = "total_tracks"
        case datePrecision = "release_date_precision"
        
        case artists = "artists"
        case urlImages = "images"
        
        case externalURL = "external_urls"
        enum ExternalUrlKeys: String, CodingKey {
            case spotifyURL = "spotify"
        }
        
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)
        datePrecision = try container.decode(String.self, forKey: .datePrecision)
        totalTracks = try container.decode(Int.self, forKey: .totalTracks)
        artists = try container.decode([Artist].self, forKey: .artists)
        urlImages = try container.decode([SpotifyImage].self, forKey: .urlImages)
        //uri = try container.decode(String.self, forKey: .uri)
        let externalUrlContainer = try container.nestedContainer(keyedBy: CodingKeys.ExternalUrlKeys.self, forKey: .externalURL)
        externalURL = try externalUrlContainer.decode(String.self, forKey: .spotifyURL)
        
        let dateString = try container.decode(String.self, forKey: .releaseDate)
        let dateFormatter: DateFormatter?
        switch datePrecision {
        case "year":
            dateFormatter = DateFormatter.yyyy
        case "month":
            dateFormatter = DateFormatter.yyyyMM
        case "day":
            dateFormatter = DateFormatter.yyyyMMdd
        default:
            dateFormatter = nil
        }
        guard let formatter = dateFormatter else {
            throw DecodingError.dataCorruptedError(forKey: .datePrecision, in: container, debugDescription: "Unrecognized date precision format")
        }
        //print(dateString)
        if let date = formatter.date(from: dateString) {
            releaseDate = date
        } else {
           
            throw DecodingError.dataCorruptedError(forKey: .releaseDate, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
        
    }
}


fileprivate struct AlbumsWrapper: Decodable {
    
    let albums: [Album]
    
    enum CodingKeys: String, CodingKey {
        case albums = "items"
        
    }
    
}

struct AlbumsResource: ApiResource {
    
    var methodPath: String
    var httpMethod = "GET"
    var parameters = ["include_groups=album,single", "limit=5", "market=US"]
    
    init(artist: Artist) {
        methodPath = "artists/\(artist.id)/albums"
        
    }
    func makeModel(data: Data) -> [Album]? {
        let decoder = JSONDecoder()
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

extension UIImageView {
    
    func setAlbumImage(album: Album) {
        
        if let data = album.largeImageData {
            guard let image = UIImage(data: data) else {
                print("Error: Couldn't convert album image data to UIImage")
                return
            }
            self.image = image
        } else {
            print("Error: No image data in album")
        }
    
    }

}

