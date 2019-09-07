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
    var imageData: Data?
    
    init(id: String, name: String, url: URL? = nil, image: Data? = nil) {
        self.id = id
        self.name = name
        self.urlImages = [SpotifyImage]()
        self.imageData = image
        
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

fileprivate struct ArtistSearchWrapper: Decodable {
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
    func setArtistImage(artist: Artist) {//, loader: OAuth2DataLoader? = nil) {
        /*
        if let loader = loader, artist.imageData == nil {
            guard let urlImage = artist.urlImages?.last else {
                print("Error: No urlImages provided and no image data in artist")
                return
            }
            let request = ImageRequest(url: urlImage.url, loader: loader)
            request.load() { [unowned self]
                image in
                guard let image = image else {
                    return
                }
                self.image = image
                self.setRounded()
            }
        } else {
        */
        
        if let data = artist.imageData {
            guard let image = UIImage(data: data) else {
                print("Error: Couldn't convert artist image data to UIImage")
                return
            }
            self.image = image
            self.setRounded()
        } else {
            print("Error: No image data in artist")
        }
        
    }
}

