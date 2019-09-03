//
//  Artist.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 8/31/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

import Foundation

struct Artist: Equatable {
    
    let id: String
    let name: String
    let urlImages: [SpotifyImage]
    var image: Data?
    
    init(id: String, name: String, url: URL? = nil, image: Data? = nil) {
        self.id = id
        self.name = name
        self.urlImages = [SpotifyImage]()
        self.image = image
        
    }
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.id == rhs.id
    }
    func convertImageToData() -> Bool {
        return false
    }
    
}
extension Artist: Decodable {
    
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
    //var headers: [String : String]
    var httpMethod = "GET"
    var parameters = ["type=artist"]
    
    init(searchText: String) {// , authToken: String) {
        parameters.append("q=\(searchText)*")
        //headers = ["Authorization":"Bearer "+authToken]
        
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
        
        //Debugging
        
        //dump(String(data: data, encoding: .utf8))
        /*
         do {
         let wrapped = try decoder.decode(AlbumsWrapper.self, from: data)
         } catch {
         print(error)
         }
         */
    }
}
