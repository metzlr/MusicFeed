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
    var artists: [Artist]
    var urlImages: [SpotifyImage]
    var imageData: Data?
    
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
        case type = "type"
        case name = "name"
        case releaseDate = "release_date"
        case totalTracks = "total_tracks"
        case datePrecision = "release_date_precision"
        
        case artists = "artists"
        case urlImages = "images"
        
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
    var parameters = ["include_groups=album,single", "limit=7", "market=US"]
    
    init(artist: Artist) {
        methodPath = "artists/\(artist.id)/albums"
        
    }
    func makeModel(data: Data) -> [Album]? {
        let decoder = JSONDecoder()
        // If error comes up where it gets albums that dont have this format, I think its necessary to set up custom init(from: decoder) for Album to handle the different date precisions
        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
        
        //dump(String(data: data, encoding: .utf8))
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
        /*
        if let loader = loader, album.imageData == nil {
            guard let urlImage = album.urlImages.last else {
                print("Error: No urlImages provided and no image data")
                return
            }
            let request = ImageRequest(url: urlImage.url, loader: loader)
            request.load() { [unowned self]
                image in
                guard let image = image else {
                    return
                }
                self.image = image
            }
        } else {
        */
        if let data = album.imageData {
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

