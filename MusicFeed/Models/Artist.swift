//
//  Artist.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 8/31/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation
import UIKit
import OAuth2

struct Artist: Equatable {
    
    let id: String
    let name: String
    let urlImages: [SpotifyImage]?
    var profileImageData: Data? = UIImage(named: "default-profile")!.pngData()
    var largeImageData: Data?
    
    init(id: String, name: String, url: URL? = nil, profileImage: Data? = nil) {
        self.id = id
        self.name = name
        self.urlImages = [SpotifyImage]()
        self.profileImageData = profileImage
        
    }
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.id == rhs.id
    }
    func convertImageToData() -> Bool {
        return false
    }
    
}
extension Artist: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case urlImages = "images"
    }
}

struct ArtistSearchWrapper: Decodable {
    struct ArtistItems: Decodable {
        let items: [Artist]
    }
    let artists: ArtistItems
}


struct ArtistSearchResource: ApiResource {
    
    var methodPath = "search"
    var httpMethod = "GET"
    var parameters = ["type=artist"]
    
    init(searchText: String) {
        parameters.append("q=\(searchText)*")
        
    }
    func makeModel(data: Data) -> [Artist]? {
        let decoder = JSONDecoder()
        
        do {
            let wrapped = try decoder.decode(ArtistSearchWrapper.self, from: data)
            return wrapped.artists.items
        } catch {
            print("DECODE FAILED")
            print(error)
            return nil
        }
        
    }
}
extension UIImageView {
    func setArtistImage(artist: Artist) {
        
        if let data = artist.profileImageData {
            guard let image = UIImage(data: data) else {
                print("Error: Couldn't convert artist image data to UIImage")
                self.image = UIImage(named: "default-profile")
                return
            }
            self.image = image
            self.setRounded()
        } else {
            print("Error: No image data in artist")
        }
        
    }
}

